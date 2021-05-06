defmodule Werewolf.Action.Overrule do
  alias Werewolf.Action.Helpers.FilterHelper
  alias Werewolf.KillTarget

  def resolve(players, phase_number) do
    with {:ok, players_with_item} <-
           FilterHelper.find_players_for_items(Map.values(players), [:scales_of_justice]),
         {:ok, player_and_valid_actions} <-
           FilterHelper.find_actions_for_phase(
             players_with_item,
             players,
             phase_number,
             :overrule
           ) do
      {:ok,
       Enum.reduce(player_and_valid_actions, players, fn {_player, action}, acc_players ->
         put_in(
           acc_players[action.target].alive,
           false
         )
       end),
       Enum.map(player_and_valid_actions, fn {_player, action} ->
         KillTarget.new(:overrule, action.target)
       end)}
    else
      nil -> {:ok, players, nil}
    end
  end
end
