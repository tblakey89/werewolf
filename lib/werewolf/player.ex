defmodule Werewolf.Player do
  alias Werewolf.Player
  
  @enforce_keys [:name, :host]
  defstruct [:name,
            host: false,
            role: :none,
            alive: true,
            actions: %{}]

  @villager_to_werewolf 6

  def new(type, user) do
    {:ok, %Player{name: user.username, host: type == :host}}
  end

  def roles() do
    [:villager, :werewolf]
  end

  def add_action(player, phase_number, action) do
    cond do
      Map.has_key?(player.actions, phase_number) &&
        Map.has_key?(player.actions[phase_number], action.type) ->
        {:error, :action_already_exists}
      Map.has_key?(player.actions, phase_number) ->
        actions = Map.merge(%{action.type => action}, player.actions[phase_number])
        {:ok, put_in(player.actions[phase_number], actions)}
      true ->
        {:ok, put_in(player.actions[phase_number], %{action.type => action})}
    end
  end

  def assign_roles(players) do
    length(players)
    |> generate_role_list()
    |> Enum.zip(players)
    |> Enum.reduce(%{}, fn({role, player}, acc) ->
      Map.put(acc, player.name, Map.put(player, :role, role))
    end)
  end

  def kill_player(players, :none), do: {:ok, players, win_check(players)}
  def kill_player(players, target) do
    players = put_in(players[target.name].alive, false)
    {:ok, players, win_check(players)}
  end

  defp by_role(players) do
    Enum.filter(players, fn({_, player}) -> player.alive end)
    |> Enum.reduce(%{villager: 0, werewolf: 0}, fn({_key, %{role: role}}, acc) ->
      Map.update!(acc, role, &(&1 + 1))
    end)
  end

  defp generate_role_list(player_count) do
    Enum.flat_map(role_numbers(player_count), fn({role, count}) ->
      for _ <- 1..count, do: role 
    end)
    |> Enum.shuffle
  end

  defp role_numbers(player_count) do
    werewolf_count = round(Float.floor(player_count / @villager_to_werewolf) + 1)
    villager_count = round(player_count - werewolf_count)
    %{werewolf: werewolf_count, villager: villager_count}
  end

  defp win_check(players) do
    role_count = by_role(players)
    cond do
      role_count[:werewolf] == 0 && role_count[:villager] == 0 -> :tie
      role_count[:werewolf] == 0 -> :village_win
      role_count[:villager] == 0 -> :werewolf_win
      true -> :no_win
    end
  end
end
