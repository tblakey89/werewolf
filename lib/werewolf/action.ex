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
           inspect_answer(player.role, acc_players[action.target], phase_number)
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
           find_players_for_dead_man_switch(Map.values(players), targets),
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
       Enum.map(player_and_valid_actions, fn {_player, action} ->
         KillTarget.new(:hunt, action.target)
       end)}
    else
      nil -> players
    end
  end

  def resolve_poison_action(players, phase_number, heal_targets) do
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
       Enum.map(player_and_valid_actions, fn {_player, action} ->
         KillTarget.new(:poison, action.target)
       end)}
    else
      nil -> players
    end
  end

  def resolve_resurrect_action(players, phase_number) do
    with {:ok, players_with_item} <-
           find_players_for_items(Map.values(players), [:resurrection_scroll]),
         {:ok, player_and_actions} <-
           find_resurrect_actions_for_phase(players_with_item, players, phase_number) do
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
      nil -> players
    end
  end

  defp find_players_for_items(players, item_types) do
    {:ok,
     Enum.filter(players, fn player ->
       Player.has_item?(player, item_types)
     end)}
  end

  defp find_players_for_dead_man_switch(players, targets) do
    target_ids = Enum.map(targets, fn target -> target.target end)

    {:ok,
     Enum.filter(players, fn player ->
       Player.has_item?(player, [:dead_man_switch]) && Enum.member?(target_ids, player.id)
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

  defp find_resurrect_actions_for_phase(players_with_item, players, phase_number) do
    {:ok,
     Enum.reduce(players_with_item, [], fn player, player_and_actions ->
       with {:ok, action} <- find_action(player.actions, phase_number, :resurrect),
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

  defp inspect_answer(:little_girl, target_player, phase_number) do
    Map.has_key?(target_player.actions, phase_number)
  end

  defp inspect_answer(_, target_player, _) do
    target_player.role
  end
end
