defmodule Werewolf.ActionRules do
  alias Werewolf.{Rules, Player, Action, Item, Options}

  def valid(
        %Rules{state: :day_phase},
        %Player{alive: true} = player,
        %Action{type: :vote} = action,
        players,
        _
      )
      when action.target != "no_kill" do
    response(player, action, players)
  end

  def valid(
        %Rules{state: :day_phase},
        %Player{alive: true},
        %Action{type: :vote, target: "no_kill"} = action,
        players,
        %Options{allow_no_kill_vote: true}
      ) do
    {:ok, action}
  end

  def valid(
        %Rules{state: :day_phase},
        %Player{alive: true, items: items} = player,
        %Action{type: action_type} = action,
        players,
        _
      ) do
    cond do
      action_type == :curse && Item.usable?(:cursed_relic, items) ->
        response(player, action, players)

      action_type == :overrule && Item.usable?(:scales_of_justice, items) ->
        response(player, action, players)

      action_type == :defend && Item.usable?(:defence_case, items) ->
        response(player, action, players)

      action_type == :imprison && Item.usable?(:lock, items) ->
        response(player, action, players)

      true ->
        {:error, :invalid_action}
    end
  end

  def valid(
        %Rules{state: :night_phase},
        %Player{alive: true, team: :werewolf} = player,
        %Action{type: :vote} = action,
        players,
        _
      )
      when action.target != "no_kill" do
    response(player, action, players)
  end

  def valid(
        %Rules{state: :night_phase},
        %Player{alive: true, team: :serial_killer} = player,
        %Action{type: :strangle} = action,
        players,
        _
      ) do
    response(player, action, players)
  end

  def valid(
        %Rules{state: :night_phase},
        %Player{alive: true, team: :werewolf},
        %Action{type: :vote, target: "no_kill"} = action,
        players,
        %Options{allow_no_kill_vote: true}
      ) do
    {:ok, action}
  end

  def valid(
        %Rules{state: :night_phase},
        %Player{alive: true, items: items} = player,
        %Action{type: action_type} = action,
        players,
        _
      ) do
    cond do
      action_type == :heal && Item.usable?(:first_aid_kit, items) ->
        response(player, action, players)

      action_type == :inspect && Item.usable?(:magnifying_glass, items) ->
        response(player, action, players)

      action_type == :watch && Item.usable?(:binoculars, items) ->
        response(player, action, players)

      action_type == :hunt && Item.usable?(:dead_man_switch, items) ->
        response(player, action, players)

      action_type == :resurrect && Item.usable?(:resurrection_scroll, items) ->
        dead_target_response(player, action, players)

      action_type == :poison && Item.usable?(:poison, items) ->
        response(player, action, players)

      action_type == :assassinate && Item.usable?(:sword, items) ->
        response(player, action, players)

      action_type == :steal && Item.usable?(:lock_pick, items) ->
        response(player, action, players)

      action_type == :sabotage && Item.usable?(:hammer, items) ->
        response(player, action, players)

      action_type == :transform && Item.usable?(:transformation_scroll, items) ->
        response(player, action, players)

      action_type == :bite && Item.usable?(:lycans_tooth, items) ->
        response(player, action, players)

      action_type == :disentomb && Item.usable?(:pick, items) ->
        dead_target_response(player, action, players)

      action_type == :summon && Item.usable?(:summoning_scroll, items) ->
        dead_target_response(player, action, players)

      true ->
        {:error, :invalid_action}
    end
  end

  def valid(_rules, _player, _action, _players, _options) do
    {:error, :invalid_action}
  end

  defp valid_target?(target, players) do
    Player.alive?(players, target)
  end

  defp response(player, action, players) do
    case valid_target?(action.target, players) && !Player.blocking_status?(player) do
      true -> {:ok, action}
      false -> {:error, :invalid_target}
    end
  end

  defp dead_target_response(_player, action, players) do
    case !Player.alive?(players, action.target) && !Player.ghost?(players, action.target) do
      true -> {:ok, action}
      false -> {:error, :invalid_target}
    end
  end
end
