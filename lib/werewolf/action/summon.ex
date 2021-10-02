defmodule Werewolf.Action.Summon do
  alias Werewolf.Action.Helpers.FilterHelper
  alias Werewolf.{Player, Action}

  def resolve(players, phase_number) do
    with {:ok, players_with_item} <-
           FilterHelper.find_players_for_items(Map.values(players), [:summoning_scroll]),
         {:ok, player_and_actions} <-
           FilterHelper.find_actions_for_dead_for_phase(
             players_with_item,
             players,
             phase_number,
             :summon
           ) do
      {:ok,
       Enum.reduce(player_and_actions, players, fn {player, action}, acc_players ->
         {:ok, summoned_player} =
           acc_players[action.target]
           |> Player.add_action(phase_number, generate_summoned_action(action.target))

        put_in(
          acc_players[player.id].actions[phase_number][:summon].result, action.target
        )
         |> Map.put(action.target, %{
           summoned_player
           | role: :ghost,
             lover: false,
             items: [],
             win_condition: Player.role_default_win_condition(acc_players[action.target].role)
         })
       end)}
    else
      nil -> {:ok, players}
    end
  end

  defp generate_summoned_action(target) do
    %Action{type: :summoned, target: target}
  end
end
