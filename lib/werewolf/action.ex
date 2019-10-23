defmodule Werewolf.Action do
  alias __MODULE__

  @enforce_keys [:type, :target]
  @derive Jason.Encoder
  defstruct [:type, :target, :result, :seen, option: :none]

  def new(type, target) do
    %Action{type: type, target: target}
  end

  def resolve_inspect_action(players, phase_number) do
    with {:ok, player} <- find_player_for_action(players, :detective),
         {:ok, action} <- find_action_for_phase(player.actions, phase_number, :inspect) do
      {:ok,
       put_in(
         players[player.id].actions[phase_number][:inspect].result,
         players[action.target].role
       )}
    else
      nil -> {:ok, players}
    end
  end

  def resolve_heal_action(players, phase_number) do
    with {:ok, player} <- find_player_for_action(players, :doctor),
         {:ok, action} <- find_action_for_phase(player.actions, phase_number, :heal) do
      {:ok, action.target}
    else
      nil -> {:ok, :none}
    end
  end

  defp find_player_for_action(players, role) do
    case Enum.find(players, fn {id, player} ->
           player.role == role && player.alive
         end) do
      {id, player} -> {:ok, player}
      nil -> nil
    end
  end

  defp find_action_for_phase(actions, phase_number, type) do
    case actions[phase_number][type] do
      nil -> nil
      action -> {:ok, action}
    end
  end
end
