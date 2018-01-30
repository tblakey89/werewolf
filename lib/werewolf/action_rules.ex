defmodule Werewolf.ActionRules do
  alias Werewolf.{Rules, Player, Action}

  def valid(%Rules{state: :day_phase},
            %Player{alive: true},
            %Action{type: :vote} = action) do
    case action.target.alive do
      true -> {:ok, action}
      false -> {:error, :invalid_target}
    end
  end

  def valid(%Rules{state: :night_phase},
            %Player{alive: true, role: :werewolf},
            %Action{type: :vote} = action) do
    case action.target.alive do
      true -> {:ok, action}
      false -> {:error, :invalid_target}
    end
  end

  def valid(_rules, _player, _action) do
    {:error, :invalid_action}
  end
end
