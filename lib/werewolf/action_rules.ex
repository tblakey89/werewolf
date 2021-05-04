defmodule Werewolf.ActionRules do
  alias Werewolf.{Rules, Player, Action, Item}

  def valid(
        %Rules{state: :day_phase},
        %Player{alive: true},
        %Action{type: :vote} = action,
        players
      ) do
    response(action, players)
  end

  def valid(
        %Rules{state: :day_phase},
        %Player{alive: true, items: items},
        %Action{type: action_type} = action,
        players
      ) do
    cond do
      action_type == :curse && Item.usable?(:cursed_relic, items) ->
        response(action, players)

      action_type == :overrule && Item.usable?(:scales_of_justice, items) ->
        response(action, players)

      action_type == :defend && Item.usable?(:defence_case, items) ->
        response(action, players)

      true ->
        {:error, :invalid_action}
    end
  end

  def valid(
        %Rules{state: :night_phase},
        %Player{alive: true, role: :werewolf},
        %Action{type: :vote} = action,
        players
      ) do
    response(action, players)
  end

  def valid(
        %Rules{state: :night_phase},
        %Player{alive: true, items: items},
        %Action{type: action_type} = action,
        players
      ) do
    cond do
      action_type == :heal && Item.usable?(:first_aid_kit, items) ->
        response(action, players)

      action_type == :inspect && Item.usable?(:magnifying_glass, items) ->
        response(action, players)

      action_type == :inspect && Item.usable?(:binoculars, items) ->
        response(action, players)

      action_type == :hunt && Item.usable?(:dead_man_switch, items) ->
        response(action, players)

      action_type == :resurrect && Item.usable?(:resurrection_scroll, items) ->
        dead_target_response(action, players)

      action_type == :poison && Item.usable?(:poison, items) ->
        response(action, players)

      action_type == :assassinate && Item.usable?(:sword, items) ->
        response(action, players)

      action_type == :steal && Item.usable?(:lock_pick, items) ->
        response(action, players)

      action_type == :sabotage && Item.usable?(:hammer, items) ->
        response(action, players)

      action_type == :transform && Item.usable?(:transformation_scroll, items) ->
        response(action, players)

      action_type == :disentomb && Item.usable?(:pick, items) ->
        dead_target_response(action, players)

      true ->
        {:error, :invalid_action}
    end
  end

  def valid(_rules, _player, _action, _players) do
    {:error, :invalid_action}
  end

  defp valid_target?(target, players) do
    Player.alive?(players, target)
  end

  defp response(action, players) do
    case valid_target?(action.target, players) do
      true -> {:ok, action}
      false -> {:error, :invalid_target}
    end
  end

  defp dead_target_response(action, players) do
    case !Player.alive?(players, action.target) do
      true -> {:ok, action}
      false -> {:error, :invalid_target}
    end
  end
end
