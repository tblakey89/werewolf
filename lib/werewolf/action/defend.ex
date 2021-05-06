defmodule Werewolf.Action.Defend do
  alias Werewolf.Action.Helpers.FilterHelper

  def resolve(players, phase_number) do
    with {:ok, players_with_item} <-
           FilterHelper.find_players_for_items(Map.values(players), [:defence_case]),
         {:ok, player_and_actions} <-
           FilterHelper.find_actions_for_phase(players_with_item, players, phase_number, :defend) do
      {:ok, Enum.map(player_and_actions, fn {_player, action} -> action.target end)}
    else
      nil -> {:ok, []}
    end
  end
end
