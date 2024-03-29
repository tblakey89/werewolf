defmodule Werewolf.Game do
  alias Werewolf.{
    Game,
    Player,
    PlayerRules,
    Rules,
    ActionRules,
    Action,
    Votes,
    Phase,
    KillTarget,
    WinCheck,
    Options
  }

  @enforce_keys [:id, :players, :phase_length]
  @derive Jason.Encoder
  defstruct [
    :id,
    :players,
    :phase_length,
    :end_phase_unix_time,
    win_status: :no_win,
    wins: [],
    phases: 0,
    targets: %{},
    allowed_roles: [],
    options: %Options{}
  ]

  def new(nil, name, phase_length, allowed_roles, options) do
    case Enum.member?(phase_lengths(), phase_length) do
      true ->
        {:ok,
         %Game{
           id: name,
           allowed_roles: allowed_roles,
           players: %{},
           phase_length: phase_length,
           options: options
         }}

      false ->
        {:error, :invalid_phase_length}
    end
  end

  def new(user, name, phase_length, allowed_roles, options) do
    {:ok, host_player} = Player.new(:host, user)

    case Enum.member?(phase_lengths(), phase_length) do
      true ->
        {:ok,
         %Game{
           id: name,
           allowed_roles: allowed_roles,
           players: %{user.id => host_player},
           phase_length: phase_length,
           options: options
         }}

      false ->
        {:error, :invalid_phase_length}
    end
  end

  def edit(game, rules, phase_length, allowed_roles, options) do
    with {:ok, rules} <- Rules.check(rules, {:edit_game, game}),
         true <- Enum.member?(phase_lengths(), phase_length) do
      {:ok,
       %{
         game
         | allowed_roles: allowed_roles,
           phase_length: phase_length,
           options: options
       }}
    else
      {:error, reason} -> {:error, reason}
      false -> {:error, :invalid_phase_length}
    end
  end

  def add_player(game, user, rules) do
    with {:ok, rules} <- Rules.check(rules, {:add_player, game}),
         {:ok, players} <- PlayerRules.unique_check(game.players, user) do
      {:ok, new_player} = Player.new(:player, user)

      {:ok,
       %{
         game
         | players: Map.put(game.players, user.id, new_player)
       }, rules}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def remove_player(game, user, rules) do
    with :ok <- PlayerRules.standard_player_check(game.players, user),
         {:ok, rules} <- Rules.check(rules, {:remove_player, game}) do
      {:ok,
       %{
         game
         | players: Map.delete(game.players, user.id)
       }, rules}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def launch_game(game, user, rules) do
    with :ok <- PlayerRules.host_check(game.players, user),
         {:ok, rules} <- Rules.check(rules, :launch) do
      players =
        Player.assign_roles(game.players, game.allowed_roles)
        |> Player.Lovers.assign(game.options)
        |> Player.LycanCurse.assign(game.options)

      {:ok,
       %{
         game
         | phases: 1,
           end_phase_unix_time: Phase.calculate_end_of_phase_unix(game.phase_length),
           players: players
       }, rules}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def action(game, user, rules, action) do
    # a user can only have type of each action per phase,
    # assume it is valid, till after the action is generated
    # but do not then put it into the player's action
    # the action target must be a player struct
    # the target of the action, has to be a player struct
    with {:ok, player} <- PlayerRules.player_check(game.players, user),
         {:ok, action} <- ActionRules.valid(rules, player, action, game.players, game.options),
         {:ok, player} <- Player.add_action(player, game.phases, action, game.options) do
      {:ok, put_in(game.players[player.id], player)}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def cancel_action(game, user, rules, action_type) do
    with {:ok, player} <- PlayerRules.player_check(game.players, user),
         :ok <- Options.check(game.options, :change_action, nil),
         {:ok, player} <- Player.remove_action(player, game.phases, action_type) do
      {:ok, put_in(game.players[player.id], player)}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def claim_role(game, user, rules, claim) do
    with {:ok, rules} <- Rules.check(rules, :claim_role),
         :ok <- Options.check(game.options, :claim_role, user),
         {:ok, player} <- PlayerRules.player_check(game.players, user),
         {:ok, player} <- Player.claim_role(player, claim) do
      {:ok, put_in(game.players[player.id], player)}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def end_phase(game, user, rules) do
    with :ok <- PlayerRules.host_check(game.players, user),
         :ok <- Options.check(game.options, :end_phase, user),
         {:ok, players} <- Action.Sabotage.resolve(game.players, game.phases),
         {:ok, players, overrule_targets} <- Action.Overrule.resolve(players, game.phases),
         {:ok, defend_targets} <- Action.Defend.resolve(players, game.phases),
         {:ok, heal_targets} <- Action.Heal.resolve(players, game.phases),
         {:ok, players} <- Action.Inspect.resolve(players, game.phases, game.options),
         {:ok, players} <- Action.Watch.resolve(players, game.phases),
         {:ok, players, win_status, targets} <-
           Action.Vote.resolve(
             players,
             game.phases,
             heal_targets,
             defend_targets,
             overrule_targets
           ),
         {:ok, players, targets} <-
           Action.Strangle.resolve(players, game.phases, targets, heal_targets),
         {:ok, players, targets} <-
           Action.Poison.resolve(players, game.phases, targets, heal_targets),
         {:ok, players, targets} <-
           Action.Assassinate.resolve(
             players,
             game.phases,
             targets,
             heal_targets
           ),
         {:ok, players, targets} <- Action.Suicide.resolve(players, targets),
         {:ok, players, targets} <-
           Action.Hunt.resolve(
             players,
             game.phases,
             targets,
             heal_targets
           ),
         {:ok, players, targets} <-
           Action.Curse.resolve(
             players,
             game.phases,
             targets,
             heal_targets
           ),
         {:ok, players, targets} <-
           Action.Bite.resolve(players, game.phases, targets, heal_targets),
         {:ok, players} <- Action.Disentomb.resolve(players, game.phases),
         {:ok, players, resurrect_targets} <-
           Action.Resurrect.resolve(players, game.phases),
         {:ok, players} <- Action.Summon.resolve(players, game.phases),
         {:ok, players} <- Action.Imprison.resolve(players, game.phases),
         {:ok, players} <- Action.BeatUp.resolve(players, game.phases, heal_targets),
         {:ok, players} <- Action.Steal.resolve(players, game.phases),
         # suicide action can be called twice, as will not add game event twice
         # this is to ensure it also triggers both the hunt action, and the hunt
         # target is affected by the result
         {:ok, players, targets} <- Action.Suicide.resolve(players, targets),
         {:ok, players} <-
           Player.clear_players_statuses(players, Player.remove_phase_statuses(game.phases)),
         {:ok, players} <- Player.use_items(players, game.phases),
         {:ok, wins} <- WinCheck.check_for_wins(win_status, players),
         {:ok, wins} <- check_phase_limit(players, game.phases, wins),
         {:ok, rules} <- Rules.check(rules, {:end_phase, wins}) do
      phase_targets = targets ++ resurrect_targets
      win_status = Enum.at(wins, 0) || :no_win

      game_targets =
        Map.put(
          game.targets,
          game.phases,
          Enum.shuffle(phase_targets)
        )

      game = %{
        game
        | phases: game.phases + 1,
          players: players,
          win_status: win_status,
          wins: wins,
          targets: game_targets,
          end_phase_unix_time: Phase.calculate_end_of_phase_unix(game.phase_length)
      }

      {:ok, game, rules, KillTarget.to_map(phase_targets), win_status, wins}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def end_game(game, user, rules) do
    with :ok <- PlayerRules.host_check(game.players, user),
         :ok <- Options.check(game.options, :end_game, user),
         {:ok, rules} <- Rules.check(rules, {:end_phase, :host_end}) do
      {:ok,
       %{
         game
         | win_status: :host_end
       }, rules}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def relevant_players(:standard, game, _rules) do
    Map.keys(game.players)
  end

  def relevant_players(type, game, rules) do
    case Rules.is_playing?(rules) do
      true ->
        Map.values(game.players)
        |> Enum.filter(fn player ->
          Player.relevant_player?(rules.state, player, type)
        end)
        |> Enum.map(fn player -> player.id end)

      false ->
        []
    end
  end

  def phase_lengths() do
    [
      :millisecond,
      :second,
      :two_minute,
      :five_minute,
      :thirty_minute,
      :hour,
      :hours,
      :twelve_hour,
      :day
    ]
  end

  def current_vote_count(game) do
    {:ok, votes, target} = Action.Vote.count_from_actions(game.players, game.phases)

    vote_tuples =
      Enum.map(votes, fn {key, value} -> {key, value} end)
      |> List.keysort(1)
      |> Enum.reverse()

    {vote_tuples, target}
  end

  defp check_phase_limit(players, phases, []) when map_size(players) * 2 <= phases do
    {:ok, [:too_many_phases]}
  end

  defp check_phase_limit(_, _, win_status), do: {:ok, win_status}
end
