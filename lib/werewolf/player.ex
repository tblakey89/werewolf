defmodule Werewolf.Player do
  import Guard, only: [is_even: 1]
  alias Werewolf.Player
  alias Werewolf.KillTarget
  alias Werewolf.Item

  @enforce_keys [:id, :host]
  @derive Jason.Encoder
  defstruct [:id, host: false, role: :none, alive: true, actions: %{}, items: []]

  @villager_to_werewolf 6

  @items_by_role %{
    werewolf: [],
    villager: [],
    detective: [:magnifying_glass],
    doctor: [:first_aid_kit],
    mason: [],
    little_girl: [:binoculars],
    devil: [:magnifying_glass],
    hunter: [:dead_man_switch],
    fool: []
  }

  def new(type, user) do
    {:ok, %Player{id: user.id, host: type == :host}}
  end

  def roles() do
    [:villager, :werewolf]
  end

  def inspect_roles() do
    [:detective, :little_girl, :devil]
  end

  def roles_by_team() do
    %{
      werewolf: :werewolf,
      villager: :villager,
      detective: :villager,
      doctor: :villager,
      mason: :villager,
      little_girl: :villager,
      devil: :villager,
      hunter: :villager,
      fool: :villager
    }
  end

  def additional_roles_by_number() do
    %{
      detective: 1,
      doctor: 1,
      mason: 2,
      little_girl: 1,
      devil: 1,
      hunter: 1,
      fool: 1
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
      Map.put(acc, player.id, %{player | role: role, items: items_for_role(role)})
    end)
  end

  def relevant_player?(player, :dead) do
    !player.alive
  end

  def relevant_player?(player, type) do
    player.role == type && player.alive
  end

  def kill_player(players, phase_number, target, heal_target \\ :none)

  def kill_player(players, _, :none, _), do: {:ok, players, win_check(players), []}

  def kill_player(players, phase_number, target, _) when is_even(phase_number) do
    players = put_in(players[target].alive, false)

    case players[target].role do
      :fool -> {:ok, players, :fool_win, [KillTarget.new(:vote, target)]}
      _ -> {:ok, players, win_check(players), [KillTarget.new(:vote, target)]}
    end
  end

  def kill_player(players, _, target, heal_target) when target == heal_target do
    {:ok, players, win_check(players), []}
  end

  def kill_player(players, phase_number, target, heal_target) do
    players = put_in(players[target].alive, false)

    {players, targets} =
      hunter_response(
        players,
        players[target].role,
        players[target].actions[phase_number],
        heal_target,
        [KillTarget.new(:werewolf, target)]
      )

    {:ok, players, win_check(players), targets}
  end

  defp items_for_role(role) do
    Enum.map(@items_by_role[role], fn item_type ->
      Item.new(item_type)
    end)
  end

  defp hunter_response(players, :hunter, nil, _, targets), do: {players, targets}

  defp hunter_response(players, :hunter, actions, heal_target, targets) do
    with true <- Map.has_key?(actions, :hunt),
         false <- actions[:hunt].target == heal_target,
         %Player{alive: true} <- players[actions[:hunt].target] do
      hunt_action = actions[:hunt]
      players = put_in(players[hunt_action.target].alive, false)
      {players, targets ++ [KillTarget.new(:hunter, hunt_action.target)]}
    else
      _ -> {players, targets}
    end
  end

  defp hunter_response(players, _, _, _, targets), do: {players, targets}

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

    {villager_count, updated_additional_roles} =
      village_role_count(player_count, werewolf_count, allowed_roles)

    initial_roles = %{werewolf: werewolf_count, villager: villager_count}

    Enum.reduce(updated_additional_roles, initial_roles, fn role, roles ->
      Map.put(roles, role, additional_roles_by_number()[role])
    end)
    |> Enum.reject(fn {role, count} -> count == 0 end)
  end

  defp village_role_count(player_count, werewolf_count, allowed_roles) do
    additional_count =
      Enum.reduce(allowed_roles, 0, fn role, acc ->
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
