defmodule Werewolf.Player do
  alias Werewolf.Player
  alias Werewolf.KillTarget

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

  def additional_roles_by_number() do
    %{
      detective: 1,
      doctor: 1
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

  def assign_roles(players, allowed_roles \\ [:detective, :doctor]) do
    map_size(players)
    |> generate_role_list(allowed_roles)
    |> Enum.zip(Map.values(players))
    |> Enum.reduce(%{}, fn {role, player}, acc ->
      Map.put(acc, player.id, Map.put(player, :role, role))
    end)
  end

  def kill_player(players, target, heal_target \\ :none)

  def kill_player(players, :none, _), do: {:ok, players, win_check(players), []}

  def kill_player(players, target, heal_target) when target == heal_target do
    {:ok, players, win_check(players), []}
  end

  def kill_player(players, target, _heal_target) do
    players = put_in(players[target].alive, false)
    {:ok, players, win_check(players), [KillTarget.new(:werewolf, target)]}
  end

  defp by_team(players) do
    Enum.filter(players, fn {_, player} -> player.alive end)
    |> Enum.reduce(%{villager: 0, werewolf: 0}, fn {_key, %{role: role}}, acc ->
      Map.update!(acc, player_team(role), &(&1 + 1))
    end)
  end

  defp generate_role_list(player_count, allowed_roles) do
    Enum.flat_map(role_numbers(player_count, allowed_roles), fn {role, count} ->
      for _ <- 1..count, do: role
    end)
    |> Enum.shuffle()
  end

  defp role_numbers(player_count, allowed_roles) do
    werewolf_count = round(Float.floor(player_count / @villager_to_werewolf) + 1)
    {villager_count, updated_additional_roles} = village_role_count(player_count, werewolf_count, allowed_roles)
    initial_roles = %{werewolf: werewolf_count, villager: villager_count}
    Enum.reduce(updated_additional_roles, initial_roles, fn role, roles ->
      Map.put(roles, role, additional_roles_by_number()[role])
    end)
    |> Enum.reject(fn {role, count} -> count == 0 end)
  end

  defp village_role_count(player_count, werewolf_count, allowed_roles) do
    additional_count = Enum.reduce(allowed_roles, 0, fn role, acc ->
      additional_roles_by_number()[role] + acc
    end)

    villager_count = round(player_count - werewolf_count - additional_count)

    cond do
      villager_count >= 0 ->
        {villager_count, allowed_roles}
      villager_count < 0 ->
        village_role_count(player_count, werewolf_count, Enum.shuffle(allowed_roles) |> tl())
    end
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
