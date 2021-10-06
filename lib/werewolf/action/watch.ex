defmodule Werewolf.Action.Watch do
  alias Werewolf.Action.Helpers.FilterHelper
  alias Werewolf.Options
  alias Werewolf.Player

  def resolve(players, phase_number) do
    {:ok,
     with {:ok, players_with_item} <-
            FilterHelper.find_players_for_items(Map.values(players), [
              :binoculars
            ]),
          {:ok, player_and_actions} <-
            FilterHelper.find_actions_for_phase(
              players_with_item,
              players,
              phase_number,
              :watch
            ) do
       Enum.reduce(player_and_actions, players, fn {player, action}, acc_players ->
         put_in(
           acc_players[player.id].actions[phase_number][:watch].result,
           watch_target(acc_players[action.target], phase_number, players)
           |> watch_answer(phase_number, players)
         )
       end)
     else
       nil -> players
     end}
  end

  defp watch_answer(target_player, phase_number, players) do
    target_action =
      Map.values(target_player.actions[phase_number] || %{})
      |> Enum.shuffle()
      |> Enum.at(0)

    case target_action do
      nil -> 0
      _ -> target_action.target
    end
  end

  defp watch_target(target_player, phase_number, players) do
    case target_player.actions[phase_number][:transform] do
      nil -> target_player
      action -> players[action.target]
    end
  end
end
