defmodule Werewolf.Action.Disentomb do
  alias Werewolf.Action.Helpers.{FilterHelper, ItemsHelper}
  alias Werewolf.Player

  def resolve(players, phase_number) do
    with {:ok, players_with_item} <-
           FilterHelper.find_players_for_items(Map.values(players), [:pick]),
         {:ok, player_and_valid_actions} <-
           FilterHelper.find_actions_for_dead_for_phase(
             players_with_item,
             players,
             phase_number,
             :disentomb
           ) do
      {:ok,
       Enum.reduce(player_and_valid_actions, players, fn {player, action}, acc_players ->
         target_player = acc_players[action.target]
         {stolen_item, left_items} = ItemsHelper.steal_item(target_player.items)

         grave_rob_action =
           ItemsHelper.generate_item_result_action(:grave_rob, stolen_item, action.target)

         {:ok, target_player} =
           Player.update_items(target_player, left_items)
           |> Player.add_action(phase_number, grave_rob_action)

         player = Player.update_items(player, [stolen_item | player.items])

         updated_players =
           put_in(
             acc_players[action.target],
             target_player
           )

         case stolen_item do
           nil ->
             updated_players

           stolen_item ->
             put_in(
               updated_players[player.id],
               put_in(
                 player.actions[phase_number][:disentomb].result,
                 stolen_item.type
               )
             )
         end
       end)}
    else
      nil -> {:ok, players}
    end
  end
end
