defmodule Werewolf.Game do
  alias Werewolf.{Game, Player, PlayerRules, Rules, ActionRules, Action, Votes, Phase}

  @enforce_keys [:id, :players, :phase_length]
  @derive Jason.Encoder
  defstruct [
    :id,
    :players,
    :phase_length,
    :end_phase_unix_time,
    win_status: :no_win,
    phases: 0,
    targets: %{},
    allowed_roles: []
  ]

  def new(nil, name, phase_length, allowed_roles) do
    case Enum.member?(phase_lengths(), phase_length) do
      true ->
        {:ok, %Game{id: name, allowed_roles: allowed_roles, players: %{}, phase_length: phase_length}}

      false ->
        {:error, :invalid_phase_length}
    end
  end

  def new(user, name, phase_length, allowed_roles) do
    {:ok, host_player} = Player.new(:host, user)

    case Enum.member?(phase_lengths(), phase_length) do
      true ->
        {:ok, %Game{id: name, allowed_roles: allowed_roles, players: %{user.id => host_player}, phase_length: phase_length}}

      false ->
        {:error, :invalid_phase_length}
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
      {:ok,
       %{
         game
         | phases: 1,
           end_phase_unix_time: Phase.calculate_end_of_phase_unix(game.phase_length),
           players: Player.assign_roles(game.players, game.allowed_roles)
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
         {:ok, action} <- ActionRules.valid(rules, player, action, game.players),
         {:ok, player} <- Player.add_action(player, game.phases, action) do
      {:ok, put_in(game.players[player.id], player)}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def end_phase(game, rules) do
    # count votes should return loser
    # if tie, returns :none atom
    # kill player, or not if tie
    # win check
    # if win change to gameover, declare winner,
    # :werewolf_win, :village_win, otherwise
    # go to next day/night phase
    # don't need to worry about alternate paths,
    # should be same win or continue,
    # all we need to do is send the messages, let phoenix
    # handle how to broadcast the actual text
    # like:
    # {:ok, :village_win, 'player_id'} ('player_id' is player who was killed)
    # {:ok, :werewolf_win, :user_dead}
    # {:ok, :day/:night, :user_dead/:none}
    # :user_dead could in the future be replaced by list of tuples
    # [{:user_dead, :werewolf}, {:user_dead, :vigilante}], etc
    with {:ok, votes, target} <- Votes.count_from_actions(phase_actions(game)),
         {:ok, heal_target} <- Action.resolve_heal_action(game.players, game.phases),
         {:ok, players, win_status, targets} <-
           Player.kill_player(game.players, target, heal_target),
         {:ok, players} <- Action.resolve_inspect_action(players, game.phases),
         {:ok, rules} <- Rules.check(rules, {:end_phase, win_status}) do
      game_targets = Map.put(game.targets, game.phases, targets)

      game = %{
        game
        | phases: game.phases + 1,
          players: players,
          win_status: win_status,
          targets: game_targets,
          end_phase_unix_time: Phase.calculate_end_of_phase_unix(game.phase_length)
      }

      {:ok, game, rules, target, win_status}
    else
      {:error, reason} -> {:error, reason}
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
    {:ok, votes, target} = Votes.count_from_actions(phase_actions(game))
    {Enum.max(Map.values(votes)), target}
  end

  defp phase_actions(game) do
    Enum.map(game.players, fn {_, player} -> player.actions end)
    |> Enum.map(fn actions -> actions[game.phases] end)
    |> Enum.reject(fn action -> is_nil(action) end)
  end
end
