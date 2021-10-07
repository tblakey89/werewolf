defmodule Werewolf.Action.BeatUp do
  alias Werewolf.Action.Helpers.FilterHelper
  alias Werewolf.{Action, Player}

  def resolve(players, phase_number, heal_targets) do
    with {:ok, players_with_item} <-
           FilterHelper.find_players_for_items(Map.values(players), [:bat]),
         {:ok, player_and_actions} <-
           FilterHelper.find_actions_for_phase(
             players_with_item,
             players,
             phase_number,
             :beat_up
           ),
         {:ok, player_and_valid_actions} <-
           FilterHelper.remove_healed_actions(player_and_actions, heal_targets) do
      {:ok,
       Enum.reduce(player_and_valid_actions, players, fn {_player, action}, acc_players ->
         player = players[action.target]

         {:ok, player_with_action} =
           Player.add_action(player, phase_number, Action.new(:beaten_up, player.id))

         {:ok, player_with_status} = Player.add_status(player_with_action, :silenced)

         put_in(acc_players[player.id], player_with_status)
       end)}
    else
      nil -> {:ok, players, nil}
    end
  end
end
