defmodule Werewolf.Action.Assassinate do
  alias Werewolf.Action.Helpers.FilterHelper
  alias Werewolf.{Action, KillTarget, Player}

  def resolve(players, phase_number, targets, heal_targets) do
    with {:ok, players_with_item} <-
           FilterHelper.find_players_for_items(Map.values(players), [:sword]),
         {:ok, player_and_actions} <-
           FilterHelper.find_actions_for_phase(
             players_with_item,
             players,
             phase_number,
             :assassinate
           ),
         {:ok, player_and_valid_actions} <-
           FilterHelper.remove_healed_actions(player_and_actions, heal_targets) do
      {:ok,
       Enum.reduce(player_and_valid_actions, players, fn {player, action}, acc_players ->
         players =
           put_in(
             acc_players[action.target].alive,
             false
           )

         case Player.match_team?(player, acc_players[action.target]) do
           true -> add_seppuku(players, player, phase_number)
           false -> players
         end
       end),
       Enum.reduce(player_and_valid_actions, targets, fn {player, action}, acc_targets ->
         targets = acc_targets ++ [KillTarget.new(:assassinate, action.target)]

         case Player.match_team?(player, players[action.target]) && player.alive do
           true -> targets ++ [KillTarget.new(:seppuku, player.id)]
           false -> targets
         end
       end)}
    else
      nil -> {:ok, players, targets}
    end
  end

  defp add_seppuku(players, %Player{alive: false}, _), do: players

  defp add_seppuku(players, player, phase_number) do
    {:ok, player_with_action} =
      Player.add_action(player, phase_number, Action.new(:seppuku, player.id))

    put_in(
      players[player.id],
      %{
        player_with_action
        | alive: false
      }
    )
  end
end
