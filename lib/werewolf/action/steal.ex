defmodule Werewolf.Action.Steal do
  alias Werewolf.Action.Helpers.{FilterHelper, ItemsHelper}
  alias Werewolf.Player

  def resolve(players, phase_number) do
    with {:ok, players_with_item} <-
           FilterHelper.find_players_for_items(Map.values(players), [:lock_pick]),
         {:ok, player_and_valid_actions} <-
           FilterHelper.find_actions_for_phase(players_with_item, players, phase_number, :steal) do
      {:ok,
       Enum.reduce(player_and_valid_actions, players, fn {player, action}, acc_players ->
         target_player = acc_players[action.target]
         target_id = action.target

         {:ok, %{^target_id => target_player}} =
           Player.use_items(%{action.target => target_player}, phase_number)

         {stolen_item, left_items} = ItemsHelper.steal_item(target_player.items)

         theft_action =
           ItemsHelper.generate_item_result_action(:theft, stolen_item, action.target)

         {:ok, target_player} =
           Player.update_items(target_player, left_items)
           |> Player.add_action(phase_number, theft_action)

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
                 player.actions[phase_number][:steal].result,
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
