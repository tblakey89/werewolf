defmodule Werewolf.Action.Resurrect do
  alias Werewolf.Action.Helpers.FilterHelper
  alias Werewolf.KillTarget

  def resolve(players, phase_number) do
    with {:ok, players_with_item} <-
           FilterHelper.find_players_for_items(Map.values(players), [:resurrection_scroll]),
         {:ok, player_and_actions} <-
           FilterHelper.find_actions_for_dead_for_phase(
             players_with_item,
             players,
             phase_number,
             :resurrect
           ) do
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
end
