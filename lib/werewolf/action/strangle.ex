defmodule Werewolf.Action.Strangle do
  alias Werewolf.Action.Helpers.FilterHelper
  alias Werewolf.KillTarget

  def resolve(players, phase_number, targets, heal_targets) do
    with {:ok, player_and_actions} <-
           FilterHelper.find_actions_for_phase(
             Map.values(players),
             players,
             phase_number,
             :strangle
           ),
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
           KillTarget.new(:strangle, action.target)
         end)}
    else
      nil -> {:ok, players, targets}
    end
  end
end
