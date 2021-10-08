defmodule Werewolf.Action.Imprison do
  alias Werewolf.Action.Helpers.FilterHelper
  alias Werewolf.{Action, Player}

  def resolve(players, phase_number) do
    with {:ok, players_with_item} <-
           FilterHelper.find_players_for_items(Map.values(players), [:lock]),
         {:ok, player_and_valid_actions} <-
           FilterHelper.find_actions_for_phase(
             players_with_item,
             players,
             phase_number,
             :imprison
           ) do
      {:ok,
       Enum.reduce(player_and_valid_actions, players, fn {lock_player, action}, acc_players ->
         player = players[action.target]

         {:ok, player_with_action} =
           Player.add_action(player, phase_number, Action.new(:imprisoned, player.id))

         {:ok, player_with_status} = Player.add_status(player_with_action, :imprisoned)

         acc_players =
           put_in(
             acc_players[lock_player.id].actions[phase_number][:imprison].result,
             action.target
           )

         put_in(acc_players[player.id], player_with_status)
       end)}
    else
      nil -> {:ok, players, nil}
    end
  end
end
