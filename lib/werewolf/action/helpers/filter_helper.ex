defmodule Werewolf.Action.Helpers.FilterHelper do
  alias Werewolf.{Action, Player}

  def find_actions_for_phase(players_with_item, players, phase_number, type) do
    {:ok,
     Enum.reduce(players_with_item, [], fn player, player_and_actions ->
       with {:ok, action} <- find_action(player.actions, phase_number, type),
            true <- players[action.target].alive do
         [{player, action} | player_and_actions]
       else
         :error -> player_and_actions
         false -> player_and_actions
       end
     end)}
  end

  def find_players_for_items(players, item_types) do
    {:ok,
     Enum.filter(players, fn player ->
       Player.has_item?(player, item_types)
     end)}
  end

  def remove_healed_actions(player_and_actions, heal_targets) do
    {:ok,
     Enum.reject(player_and_actions, fn {_player, action} ->
       Enum.member?(heal_targets, action.target)
     end)}
  end

  def find_targetted_players_for_items(players, targets, item_types) do
    target_ids = Enum.map(targets, fn target -> target.target end)

    {:ok,
     Enum.filter(players, fn player ->
       Player.has_item?(player, item_types) && Enum.member?(target_ids, player.id)
     end)}
  end

  def find_actions_for_dead_for_phase(players_with_item, players, phase_number, type) do
    {:ok,
     Enum.reduce(players_with_item, [], fn player, player_and_actions ->
       with {:ok, action} <- find_action(player.actions, phase_number, type),
            false <- players[action.target].alive do
         [{player, action} | player_and_actions]
       else
         :error -> player_and_actions
         true -> player_and_actions
       end
     end)}
  end

  def find_action(actions, phase_number, type) do
    case actions[phase_number][type] do
      nil -> :error
      action -> {:ok, action}
    end
  end
end
