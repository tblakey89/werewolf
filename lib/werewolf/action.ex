defmodule Werewolf.Action do
  alias __MODULE__
  alias Werewolf.Player
  alias Werewolf.KillTarget

  @enforce_keys [:type, :target]
  @derive Jason.Encoder
  defstruct [:type, :target, :result, :seen, option: :none]

  def new(type, target) do
    %Action{type: type, target: target}
  end

  def resolve_inspect_action(players, phase_number) do
    {:ok,
     with {:ok, players_with_item} <-
            find_players_for_items(Map.values(players), [:magnifying_glass, :binoculars]),
          {:ok, player_and_actions} <-
            find_actions_for_phase(players_with_item, players, phase_number, :inspect) do
       Enum.reduce(player_and_actions, players, fn {player, action}, acc_players ->
         put_in(
           acc_players[player.id].actions[phase_number][:inspect].result,
           # this should be item not role
           inspect_answer(player.role, acc_players[action.target], phase_number, players)
         )
       end)
     else
       nil -> players
     end}
  end

  def resolve_heal_action(players, phase_number) do
    with {:ok, players_with_item} <-
           find_players_for_items(Map.values(players), [:first_aid_kit]),
         {:ok, player_and_actions} <-
           find_actions_for_phase(players_with_item, players, phase_number, :heal) do
      {:ok, Enum.map(player_and_actions, fn {_player, action} -> action.target end)}
    else
      nil -> {:ok, []}
    end
  end

  def resolve_hunt_action(players, phase_number, targets, heal_targets) do
    with {:ok, players_with_item} <-
           find_targetted_players_for_items(Map.values(players), targets, [:dead_man_switch]),
         {:ok, player_and_actions} <-
           find_actions_for_phase(players_with_item, players, phase_number, :hunt),
         {:ok, player_and_valid_actions} <-
           remove_healed_actions(player_and_actions, heal_targets) do
      {:ok,
       Enum.reduce(player_and_valid_actions, players, fn {_player, action}, acc_players ->
         put_in(
           acc_players[action.target].alive,
           false
         )
       end),
       targets ++
         Enum.map(player_and_valid_actions, fn {_player, action} ->
           KillTarget.new(:hunt, action.target)
         end)}
    else
      nil -> {:ok, players, targets}
    end
  end

  def resolve_curse_action(players, phase_number, targets, heal_targets) do
    with {:ok, players_with_item} <-
           find_targetted_players_for_items(Map.values(players), targets, [:cursed_relic]),
         {:ok, player_and_actions} <-
           find_actions_for_phase(players_with_item, players, phase_number, :curse),
         {:ok, player_and_valid_actions} <-
           remove_healed_actions(player_and_actions, heal_targets) do
      {:ok,
       Enum.reduce(player_and_valid_actions, players, fn {_player, action}, acc_players ->
         put_in(
           acc_players[action.target].alive,
           false
         )
       end),
       targets ++
         Enum.map(player_and_valid_actions, fn {_player, action} ->
           KillTarget.new(:curse, action.target)
         end)}
    else
      nil -> {:ok, players, targets}
    end
  end

  def resolve_poison_action(players, phase_number, targets, heal_targets) do
    with {:ok, players_with_item} <- find_players_for_items(Map.values(players), [:poison]),
         {:ok, player_and_actions} <-
           find_actions_for_phase(players_with_item, players, phase_number, :poison),
         {:ok, player_and_valid_actions} <-
           remove_healed_actions(player_and_actions, heal_targets) do
      {:ok,
       Enum.reduce(player_and_valid_actions, players, fn {_player, action}, acc_players ->
         put_in(
           acc_players[action.target].alive,
           false
         )
       end),
       targets ++
         Enum.map(player_and_valid_actions, fn {_player, action} ->
           KillTarget.new(:poison, action.target)
         end)}
    else
      nil -> {:ok, players, targets}
    end
  end

  def resolve_resurrect_action(players, phase_number) do
    with {:ok, players_with_item} <-
           find_players_for_items(Map.values(players), [:resurrection_scroll]),
         {:ok, player_and_actions} <-
           find_actions_for_dead_for_phase(players_with_item, players, phase_number, :resurrect) do
      {:ok,
       Enum.reduce(player_and_actions, players, fn {_player, action}, acc_players ->
         put_in(
           acc_players[action.target].alive,
           true
         )
       end),
       Enum.map(player_and_actions, fn {_player, action} ->
         KillTarget.new(:resurrect, action.target)
       end)}
    else
      nil -> {:ok, players, []}
    end
  end

  def resolve_assassinate_action(players, phase_number, targets, heal_targets) do
    with {:ok, players_with_item} <- find_players_for_items(Map.values(players), [:sword]),
         {:ok, player_and_actions} <-
           find_actions_for_phase(players_with_item, players, phase_number, :assassinate),
         {:ok, player_and_valid_actions} <-
           remove_healed_actions(player_and_actions, heal_targets) do
      {:ok,
       Enum.reduce(player_and_valid_actions, players, fn {player, action}, acc_players ->
         players =
           put_in(
             acc_players[action.target].alive,
             false
           )

         case Player.match_team?(player, acc_players[action.target]) do
           true -> add_seppuku(players, player, phase_number)
           false -> players
         end
       end),
       Enum.reduce(player_and_valid_actions, targets, fn {player, action}, acc_targets ->
         targets = acc_targets ++ [KillTarget.new(:assassinate, action.target)]

         case Player.match_team?(player, players[action.target]) do
           true -> targets ++ [KillTarget.new(:seppuku, player.id)]
           false -> targets
         end
       end)}
    else
      nil -> {:ok, players, targets}
    end
  end

  def resolve_steal_action(players, phase_number) do
    with {:ok, players_with_item} <- find_players_for_items(Map.values(players), [:lock_pick]),
         {:ok, player_and_valid_actions} <-
           find_actions_for_phase(players_with_item, players, phase_number, :steal) do
      {:ok,
       Enum.reduce(player_and_valid_actions, players, fn {player, action}, acc_players ->
         target_player = acc_players[action.target]
         {stolen_item, left_items} = steal_item(target_player.items)
         theft_action = generate_item_result_action(:theft, stolen_item)

         {:ok, target_player} =
           Player.update_items(target_player, left_items)
           |> Player.add_action(phase_number, theft_action)

         player = Player.update_items(player, [stolen_item | player.items])

         updated_players =
           put_in(
             acc_players[action.target],
             target_player
           )

         case stolen_item do
           nil ->
             updated_players

           stolen_item ->
             put_in(
               updated_players[player.id],
               put_in(
                 player.actions[phase_number][:steal].result,
                 stolen_item.type
               )
             )
         end
       end)}
    else
      nil -> {:ok, players}
    end
  end

  def resolve_sabotage_action(players, phase_number) do
    with {:ok, players_with_item} <- find_players_for_items(Map.values(players), [:hammer]),
         {:ok, player_and_valid_actions} <-
           find_actions_for_phase(players_with_item, players, phase_number, :sabotage) do
      {:ok,
       Enum.reduce(player_and_valid_actions, players, fn {player, action}, acc_players ->
         target_player = acc_players[action.target]
         {destroyed_item, left_items} = steal_item(target_player.items)
         sabotage_action = generate_item_result_action(:destroyed, destroyed_item)

         {:ok, target_player} =
           Player.update_items(target_player, left_items)
           |> Player.add_action(phase_number, sabotage_action)

         updated_players =
           put_in(
             acc_players[action.target],
             target_player
           )

         case destroyed_item do
           nil ->
             updated_players

           stolen_item ->
             put_in(
               updated_players[player.id],
               put_in(
                 player.actions[phase_number][:sabotage].result,
                 stolen_item.type
               )
             )
         end
       end)}
    else
      nil -> {:ok, players}
    end
  end

  def resolve_disentomb_action(players, phase_number) do
    with {:ok, players_with_item} <- find_players_for_items(Map.values(players), [:pick]),
         {:ok, player_and_valid_actions} <-
           find_actions_for_dead_for_phase(players_with_item, players, phase_number, :disentomb) do
      {:ok,
       Enum.reduce(player_and_valid_actions, players, fn {player, action}, acc_players ->
         target_player = acc_players[action.target]
         {stolen_item, left_items} = steal_item(target_player.items)
         grave_rob_action = generate_item_result_action(:grave_rob, stolen_item)

         {:ok, target_player} =
           Player.update_items(target_player, left_items)
           |> Player.add_action(phase_number, grave_rob_action)

         player = Player.update_items(player, [stolen_item | player.items])

         updated_players =
           put_in(
             acc_players[action.target],
             target_player
           )

         case stolen_item do
           nil ->
             updated_players

           stolen_item ->
             put_in(
               updated_players[player.id],
               put_in(
                 player.actions[phase_number][:disentomb].result,
                 stolen_item.type
               )
             )
         end
       end)}
    else
      nil -> {:ok, players}
    end
  end

  defp find_players_for_items(players, item_types) do
    {:ok,
     Enum.filter(players, fn player ->
       Player.has_item?(player, item_types)
     end)}
  end

  defp find_targetted_players_for_items(players, targets, item_types) do
    target_ids = Enum.map(targets, fn target -> target.target end)

    {:ok,
     Enum.filter(players, fn player ->
       Player.has_item?(player, item_types) && Enum.member?(target_ids, player.id)
     end)}
  end

  defp find_actions_for_phase(players_with_item, players, phase_number, type) do
    {:ok,
     Enum.reduce(players_with_item, [], fn player, player_and_actions ->
       with {:ok, action} <- find_action(player.actions, phase_number, type),
            true <- players[action.target].alive do
         [{player, action} | player_and_actions]
       else
         :error -> player_and_actions
         false -> player_and_actions
       end
     end)}
  end

  defp find_actions_for_dead_for_phase(players_with_item, players, phase_number, type) do
    {:ok,
     Enum.reduce(players_with_item, [], fn player, player_and_actions ->
       with {:ok, action} <- find_action(player.actions, phase_number, type),
            false <- players[action.target].alive do
         [{player, action} | player_and_actions]
       else
         :error -> player_and_actions
         true -> player_and_actions
       end
     end)}
  end

  defp find_action(actions, phase_number, type) do
    case actions[phase_number][type] do
      nil -> :error
      action -> {:ok, action}
    end
  end

  defp remove_healed_actions(player_and_actions, heal_targets) do
    {:ok,
     Enum.reject(player_and_actions, fn {_player, action} ->
       Enum.member?(heal_targets, action.target)
     end)}
  end

  defp inspect_answer(:little_girl, target_player, phase_number, _) do
    Map.has_key?(target_player.actions, phase_number)
  end

  defp inspect_answer(_, target_player, phase_number, players) do
    case target_player.actions[phase_number][:transform] do
      nil -> target_player.role
      action -> players[action.target].role
    end
  end

  defp add_seppuku(players, player, phase_number) do
    {:ok, player_with_action} =
      Player.add_action(player, phase_number, Action.new(:seppuku, player.id))

    put_in(
      players[player.id],
      %{
        player_with_action
        | alive: false
      }
    )
  end

  defp steal_item([]), do: {nil, []}

  defp steal_item(items) do
    [stolen_item | remaining_items] = Enum.shuffle(items)
    {stolen_item, remaining_items}
  end

  defp generate_item_result_action(_type, nil), do: nil

  defp generate_item_result_action(type, item) do
    %Action{type: type, result: item.type, target: 0}
  end
end
