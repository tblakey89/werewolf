defmodule Werewolf.Action.Hunt do
  alias Werewolf.Action.Helpers.FilterHelper
  alias Werewolf.KillTarget

  def resolve(players, phase_number, targets, heal_targets) do
    with {:ok, players_with_item} <-
           FilterHelper.find_targetted_players_for_items(Map.values(players), targets, [
             :dead_man_switch
           ]),
         {:ok, player_and_actions} <-
           FilterHelper.find_actions_for_phase(players_with_item, players, phase_number, :hunt),
         {:ok, player_and_valid_actions} <-
           FilterHelper.remove_healed_actions(player_and_actions, heal_targets) do
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
end
