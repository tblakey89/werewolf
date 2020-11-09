defmodule Werewolf.Action do
  alias __MODULE__
  alias Werewolf.Player

  @enforce_keys [:type, :target]
  @derive Jason.Encoder
  defstruct [:type, :target, :result, :seen, option: :none]

  def new(type, target) do
    %Action{type: type, target: target}
  end

  def resolve_inspect_action(players, phase_number) do
    {:ok,
       with {:ok, players_with_item} <- find_players_for_items(Map.values(players), [:magnifying_glass, :binoculars]),
            {:ok, player_and_actions} <- find_actions_for_phase(players_with_item, phase_number, :inspect) do
        Enum.reduce(player_and_actions, players, fn({player, action}, acc_players) ->
          put_in(
            acc_players[player.id].actions[phase_number][:inspect].result,
            # this should be item not role
            inspect_answer(player.role, acc_players[action.target], phase_number)
          )
        end)
       else
         nil -> players
       end
     }
  end

  def resolve_heal_action(players, phase_number) do
    with {:ok, players_with_item} <- find_players_for_items(Map.values(players), [:first_aid_kit]),
         {:ok, player_and_actions} <- find_actions_for_phase(players_with_item, phase_number, :heal) do
      {:ok, Enum.map(player_and_actions, fn({_player, action}) -> action.target end)}
    else
      nil -> {:ok, []}
    end
  end

  def resolve_resurrect_action(players, phase_number) do
    {:ok,
       with {:ok, players_with_item} <- find_players_for_items(Map.values(players), [:resurrection_scroll]),
            {:ok, player_and_actions} <- find_actions_for_phase(players_with_item, phase_number, :resurrect) do
        Enum.reduce(player_and_actions, players, fn({_player, action}, acc_players) ->
          put_in(
            acc_players[action.target].alive,
            true
          )
        end)
       else
         nil -> players
       end
     }
  end

  defp find_players_for_items(players, item_types) do
    {:ok, Enum.filter(players, fn player ->
           Player.has_item?(player, item_types) && player.alive
         end)}
  end

  defp find_actions_for_phase(players_with_item, phase_number, type) do
    {:ok, Enum.reduce(players_with_item, [], fn(player, player_and_actions) ->
      case player.actions[phase_number][type] do
        nil -> player_and_actions
        action -> [{player, action} | player_and_actions]
      end
    end)}
  end

  defp inspect_answer(:little_girl, target_player, phase_number) do
    Map.has_key?(target_player.actions, phase_number)
  end

  defp inspect_answer(_, target_player, _) do
    target_player.role
  end
end
