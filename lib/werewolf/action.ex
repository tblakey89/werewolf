defmodule Werewolf.Action do
  alias __MODULE__
  alias Werewolf.Player

  @enforce_keys [:type, :target]
  @derive Jason.Encoder
  defstruct [:type, :target, :result, :seen, option: :none]

  def new(type, target) do
    %Action{type: type, target: target}
  end

  def resolve_inspect_action(players, phase_number) do
    {:ok,
     Enum.reduce(Player.inspect_roles(), players, fn role, acc_players ->
       with {:ok, player} <- find_player_for_action(acc_players, role),
            {:ok, action} <- find_action_for_phase(player.actions, phase_number, :inspect) do
         put_in(
           acc_players[player.id].actions[phase_number][:inspect].result,
           inspect_answer(role, acc_players[action.target], phase_number)
         )
       else
         nil -> acc_players
       end
     end)}
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

  defp inspect_answer(:little_girl, target_player, phase_number) do
    Map.has_key?(target_player.actions, phase_number)
  end

  defp inspect_answer(_, target_player, _) do
    target_player.role
  end
end
