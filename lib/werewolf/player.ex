defmodule Werewolf.Player do
  alias Werewolf.Player

  @enforce_keys [:id, :host]
  @derive Jason.Encoder
  defstruct [:id, host: false, role: :none, alive: true, actions: %{}]

  @villager_to_werewolf 6

  def new(type, user) do
    {:ok, %Player{id: user.id, host: type == :host}}
  end

  def roles() do
    [:villager, :werewolf]
  end

  def roles_by_team() do
    %{
      werewolf: :werewolf,
      villager: :villager,
      detective: :villager,
      doctor: :villager
    }
  end

  def player_team(role) do
    roles_by_team()[role]
  end

  def alive?(players, key) do
    players[key].alive
  end

  def add_action(player, phase_number, action) do
    cond do
      Map.has_key?(player.actions, phase_number) ->
        actions = Map.merge(player.actions[phase_number], %{action.type => action})
        {:ok, put_in(player.actions[phase_number], actions)}

      true ->
        {:ok, put_in(player.actions[phase_number], %{action.type => action})}
    end
  end

  def assign_roles(players) do
    map_size(players)
    |> generate_role_list()
    |> Enum.zip(Map.values(players))
    |> Enum.reduce(%{}, fn {role, player}, acc ->
      Map.put(acc, player.id, Map.put(player, :role, role))
    end)
  end

  def kill_player(players, target, heal_target \\ :none)

  def kill_player(players, :none, _), do: {:ok, players, win_check(players)}

  def kill_player(players, target, heal_target) when target == heal_target do
    {:ok, players, win_check(players)}
  end

  def kill_player(players, target, _heal_target) do
    players = put_in(players[target].alive, false)
    {:ok, players, win_check(players)}
  end

  defp by_team(players) do
    Enum.filter(players, fn {_, player} -> player.alive end)
    |> Enum.reduce(%{villager: 0, werewolf: 0}, fn {_key, %{role: role}}, acc ->
      Map.update!(acc, player_team(role), &(&1 + 1))
    end)
  end

  defp generate_role_list(player_count) do
    Enum.flat_map(role_numbers(player_count), fn {role, count} ->
      for _ <- 1..count, do: role
    end)
    |> Enum.shuffle()
  end

  defp role_numbers(player_count) do
    werewolf_count = round(Float.floor(player_count / @villager_to_werewolf) + 1)
    villager_count = round(player_count - werewolf_count - 2)
    %{werewolf: werewolf_count, villager: villager_count, doctor: 1, detective: 1}
  end

  defp win_check(players) do
    team_count = by_team(players)

    cond do
      team_count[:werewolf] == 0 && team_count[:villager] == 0 -> :tie
      team_count[:werewolf] == 0 -> :village_win
      team_count[:werewolf] >= team_count[:villager] -> :werewolf_win
      true -> :no_win
    end
  end
end
