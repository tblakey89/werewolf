defmodule Werewolf.Player do
  alias Werewolf.Player
  alias Werewolf.KillTarget
  alias Werewolf.Item
  alias Werewolf.Options

  @enforce_keys [:id, :host]
  @derive Jason.Encoder
  defstruct [
    :id,
    host: false,
    role: :none,
    team: :none,
    alive: true,
    actions: %{},
    items: [],
    claim: :none,
    win_condition: :none,
    statuses: [],
    lover: false,
    lycan_curse: false
  ]

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
    fool: [],
    witch: [:poison, :resurrection_scroll],
    medium: [:crystal_ball],
    ninja: [:sword],
    werewolf_thief: [:lock_pick],
    werewolf_detective: [:magnifying_glass],
    werewolf_saboteur: [:hammer],
    werewolf_collector: [:cursed_relic],
    werewolf_mage: [:transformation_scroll],
    gravedigger: [:pick],
    judge: [:scales_of_justice],
    lawyer: [:defence_case]
  }

  def new(type, user) do
    {:ok, %Player{id: user.id, host: type == :host}}
  end

  def roles() do
    [:villager, :werewolf]
  end

  def inspect_roles() do
    [:detective, :little_girl, :devil, :werewolf_detective]
  end

  def roles_by_team() do
    %{
      werewolf: :werewolf,
      villager: :villager,
      detective: :villager,
      doctor: :villager,
      mason: :villager,
      little_girl: :villager,
      devil: :werewolf_aux,
      hunter: :villager,
      fool: :fool,
      witch: :villager,
      medium: :villager,
      ninja: :villager,
      werewolf_thief: :werewolf,
      werewolf_detective: :werewolf,
      werewolf_saboteur: :werewolf,
      werewolf_collector: :werewolf,
      werewolf_mage: :werewolf,
      gravedigger: :villager,
      judge: :villager,
      lawyer: :werewolf_aux
    }
  end

  def roles_by_assign() do
    %{
      werewolf: :werewolf,
      villager: :villager,
      detective: :villager,
      doctor: :villager,
      mason: :villager,
      little_girl: :villager,
      devil: :villager,
      hunter: :villager,
      fool: :villager,
      witch: :villager,
      medium: :villager,
      ninja: :villager,
      werewolf_thief: :werewolf,
      werewolf_detective: :werewolf,
      werewolf_saboteur: :werewolf,
      werewolf_collector: :werewolf,
      werewolf_mage: :werewolf,
      gravedigger: :villager,
      judge: :villager,
      lawyer: :villager
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
      fool: 1,
      witch: 1,
      medium: 1,
      ninja: 1,
      werewolf_thief: 1,
      werewolf_detective: 1,
      werewolf_saboteur: 1,
      werewolf_collector: 1,
      werewolf_mage: 1,
      gravedigger: 1,
      judge: 1,
      lawyer: 1
    }
  end

  def player_team(role) do
    roles_by_team()[role]
  end

  def role_default_win_condition(role) do
    Player.WinCondition.by_team()[roles_by_team()[role]]
  end

  def alive?(players, key) do
    players[key].alive
  end

  def match_team?(player_one, player_two) do
    player_team(player_one.role) == player_team(player_two.role)
  end

  def add_action(player, phase_number, action, options \\ %Options{})

  def add_action(player, _phase_number, nil, _), do: {:ok, player}

  def add_action(player, phase_number, action, options) do
    cond do
      Map.has_key?(player.actions, phase_number) &&
          Map.has_key?(player.actions[phase_number], action.type) ->
        case Options.check(options, :change_action, nil) do
          :ok ->
            actions = Map.merge(player.actions[phase_number], %{action.type => action})
            {:ok, put_in(player.actions[phase_number], actions)}

          {:error, error} ->
            {:error, error}
        end

      Map.has_key?(player.actions, phase_number) ->
        actions = Map.merge(player.actions[phase_number], %{action.type => action})
        {:ok, put_in(player.actions[phase_number], actions)}

      true ->
        {:ok, put_in(player.actions[phase_number], %{action.type => action})}
    end
  end

  def remove_action(player, phase_number, action_type) do
    cond do
      Map.has_key?(player.actions, phase_number) ->
        {_, actions} = Map.pop(player.actions[phase_number], action_type)
        {:ok, put_in(player.actions[phase_number], actions)}

      true ->
        {:ok, player}
    end
  end

  def claim_role(%Player{alive: false}, _), do: {:error, :dead}

  def claim_role(player, claim) do
    {:ok, put_in(player.claim, claim)}
  end

  def use_items(players, phase_number) do
    {:ok,
     Enum.reduce(Map.values(players), players, fn player, player_acc ->
       Map.put(player_acc, player.id, %{
         player
         | items: Item.use_items(player.actions[phase_number], player.items)
       })
     end)}
  end

  def update_items(player, items) do
    %{
      player
      | items: items
    }
  end

  def has_item?(player, item_types) do
    Item.includes?(item_types, player.items)
  end

  def assign_roles(players, allowed_roles \\ [:detective, :doctor]) do
    map_size(players)
    |> generate_role_list(allowed_roles)
    |> Enum.zip(Map.values(players))
    |> Enum.reduce(%{}, fn {role, player}, acc ->
      Map.put(acc, player.id, %{
        player
        | role: role,
          items: items_for_role(role),
          team: roles_by_team()[role],
          win_condition: role_default_win_condition(role)
      })
    end)
  end

  def relevant_player?(player, :dead) do
    !player.alive || has_item?(player, [:crystal_ball])
  end

  def relevant_player?(player, :mason) do
    player.role == :mason && player.alive
  end

  def relevant_player?(player, :werewolf) do
    (player.role == :werewolf && player.alive) || (player.team == :werewolf && player.alive)
  end

  def relevant_player?(player, :lover) do
    (player.lover && player.alive)
  end

  def alignment(player) do
    case roles_by_team()[player.role] do
      :villager -> :order
      _ -> :chaos
    end
  end

  defp items_for_role(role) do
    Enum.map(@items_by_role[role], fn item_type ->
      Item.new(item_type)
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
    {allowed_village_roles, allowed_werewolf_roles} = allowed_roles_by_team(allowed_roles)

    {villager_count, village_additional_roles} =
      select_roles_for_team(player_count - werewolf_count, allowed_village_roles)

    {werewolf_count, werewolf_additional_roles} =
      select_roles_for_team(werewolf_count, allowed_werewolf_roles)

    initial_roles = %{werewolf: werewolf_count, villager: villager_count}

    Enum.reduce(village_additional_roles ++ werewolf_additional_roles, initial_roles, fn role,
                                                                                         roles ->
      Map.put(roles, role, additional_roles_by_number()[role])
    end)
    |> Enum.reject(fn {role, count} -> count == 0 end)
  end

  defp allowed_roles_by_team(allowed_roles) do
    roles_by_team_map = %{werewolf: [], villager: []}

    roles_by_team_map =
      Enum.reduce(allowed_roles, roles_by_team_map, fn role, roles_by_team ->
        team = roles_by_assign()[role]
        Map.put(roles_by_team, team, [role | roles_by_team[team]])
      end)

    {roles_by_team_map[:villager], roles_by_team_map[:werewolf]}
  end

  defp select_roles_for_team(player_count, allowed_roles) do
    additional_count =
      Enum.reduce(allowed_roles, 0, fn role, acc ->
        additional_roles_by_number()[role] + acc
      end)

    regular_role_count = round(player_count - additional_count)

    cond do
      regular_role_count >= 0 ->
        {regular_role_count, allowed_roles}

      regular_role_count < 0 ->
        select_roles_for_team(player_count, Enum.shuffle(allowed_roles) |> tl())
    end
  end
end
