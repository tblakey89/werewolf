defmodule Werewolf.Action.Bite do
  alias Werewolf.Action.Helpers.FilterHelper
  alias Werewolf.{KillTarget, Player, Action}

  def resolve(players, phase_number, targets, heal_targets) do
    with {:ok, players_with_item} <-
           FilterHelper.find_players_for_items(Map.values(players), [:lycans_tooth]),
         {:ok, player_and_actions} <-
           FilterHelper.find_actions_for_phase(players_with_item, players, phase_number, :bite),
         {:ok, player_and_valid_actions} <-
           FilterHelper.remove_healed_actions(player_and_actions, heal_targets) do
      {:ok,
       Enum.reduce(player_and_valid_actions, players, fn {_player, action}, acc_players ->
         player = acc_players[action.target]

         case Player.player_team(player.role) do
           :villager ->
             convert_player(acc_players, player, phase_number)

           :werewolf_aux ->
             convert_player(acc_players, player, phase_number)

           _ ->
             put_in(
               acc_players[action.target].alive,
               false
             )
         end
       end),
       targets ++
         Enum.map(player_and_valid_actions, fn {_player, action} ->
           player = players[action.target]

           case Player.player_team(player.role) do
             :villager -> KillTarget.new(:new_werewolf, action.target)
             :werewolf_aux -> KillTarget.new(:new_werewolf, action.target)
             _ -> KillTarget.new(:bite, action.target)
           end
         end)}
    else
      nil -> {:ok, players, targets}
    end
  end

  defp convert_player(players, player, phase_number) do
    {:ok, player_with_action} =
      Player.add_action(player, phase_number, Action.new(:lycan_bite, player.id))

    put_in(
      players[player.id],
      %{
        player_with_action
        | role: :werewolf,
          team: :werewolf,
          win_condition: Player.WinCondition.win_condition_from_lycan_curse(player)
      }
    )
  end
end
