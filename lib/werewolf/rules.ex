defmodule Werewolf.Rules do
  alias __MODULE__

  defstruct state: :initialized

  @min_players 8
  @max_players 18

  def new, do: %Rules{}

  def check(%Rules{state: :initialized} = rules, {:add_player, game}) do
    case able_to_add_new_player?(game) do
      true -> {:ok, rules}
      false -> {:error, :game_full}
    end
  end

  def check(%Rules{state: :initialized} = rules, {:set_as_ready, game}) do
    case ready_to_start?(game) do
      true -> {:ok, %Rules{rules | state: :ready}}
      false -> {:error, :game_not_ready}
    end
  end

  def check(%Rules{state: :ready} = rules, :launch) do
    {:ok, %Rules{rules | state: :night_phase}}
  end

  def check(%Rules{state: :night_phase} = rules, {:end_phase, :no_win}) do
    {:ok, %Rules{rules | state: :day_phase}}
  end

  def check(%Rules{state: :day_phase} = rules, {:end_phase, :no_win}) do
    {:ok, %Rules{rules | state: :night_phase}}
  end

  def check(%Rules{state: state} = rules, {:end_phase, _})
      when state == :day_phase or state == :night_phase do
    {:ok, %Rules{rules | state: :game_over}}
  end

  def check(_state, _action), do: {:error, :invalid_action}

  defp able_to_add_new_player?(game) do
    Enum.count(game.players) + 1 <= @max_players
  end

  defp ready_to_start?(game) do
    Enum.count(game.players) >= @min_players && Enum.count(game.players) <= @max_players
  end
end
