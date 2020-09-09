defmodule Werewolf.ActionRules do
  alias Werewolf.{Rules, Player, Action}

  def valid(
        %Rules{state: :day_phase},
        %Player{alive: true},
        %Action{type: :vote} = action,
        players
      ) do
    response(action, players)
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
        %Player{alive: true, role: :doctor},
        %Action{type: :heal} = action,
        players
      ) do
    response(action, players)
  end

  def valid(
        %Rules{state: :night_phase},
        %Player{alive: true, role: :detective},
        %Action{type: :inspect} = action,
        players
      ) do
    response(action, players)
  end

  def valid(
        %Rules{state: :night_phase},
        %Player{alive: true, role: :devil},
        %Action{type: :inspect} = action,
        players
      ) do
    response(action, players)
  end

  def valid(
        %Rules{state: :night_phase},
        %Player{alive: true, role: :little_girl},
        %Action{type: :inspect} = action,
        players
      ) do
    response(action, players)
  end

  def valid(
        %Rules{state: :night_phase},
        %Player{alive: true, role: :hunter},
        %Action{type: :hunt} = action,
        players
      ) do
    response(action, players)
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
end
