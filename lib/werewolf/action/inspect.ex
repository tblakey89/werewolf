defmodule Werewolf.Action.Inspect do
  alias Werewolf.Action.Helpers.FilterHelper
  alias Werewolf.Options
  alias Werewolf.Player

  def resolve(players, phase_number, options) do
    {:ok,
     with {:ok, players_with_item} <-
            FilterHelper.find_players_for_items(Map.values(players), [
              :magnifying_glass,
              :binoculars
            ]),
          {:ok, player_and_actions} <-
            FilterHelper.find_actions_for_phase(
              players_with_item,
              players,
              phase_number,
              :inspect
            ) do
       Enum.reduce(player_and_actions, players, fn {player, action}, acc_players ->
         put_in(
           acc_players[player.id].actions[phase_number][:inspect].result,
           inspect_answer(player.role, acc_players[action.target], phase_number, players, options)
         )
       end)
     else
       nil -> players
     end}
  end

  defp inspect_answer(:little_girl, target_player, phase_number, _, _) do
    Map.has_key?(target_player.actions, phase_number)
  end

  defp inspect_answer(_, target_player, phase_number, players, %Options{
         reveal_role_on_inspect: true
       }) do
    case target_player.actions[phase_number][:transform] do
      nil -> target_player.role
      action -> players[action.target].role
    end
  end

  defp inspect_answer(_, target_player, phase_number, players, _) do
    case target_player.actions[phase_number][:transform] do
      nil -> Player.alignment(target_player)
      action -> Player.alignment(players[action.target])
    end
  end
end
