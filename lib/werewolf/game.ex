defmodule Werewolf.Game do
  alias Werewolf.{Game, Player, PlayerRules, Rules, ActionRules, Action, Votes}

  @enforce_keys [:players, :phase_length]
  defstruct [:players, :phase_length, phases: 0]

  def new(user, phase_length) do
    host_player = Player.new(:host, user)
    {:ok, %Game{players: %{user.name => host_player}, phase_length: phase_length}}
  end

  def add_player(game, user, rules) do
    with {:ok, rules} <- Rules.check(rules, {:add_player, game}),
         {:ok, players} <- PlayerRules.unique_check(game.players, user)
    do
      new_player = Player.new(:player, user)
      put_in(game, [:players, user.name], new_player)
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def set_game_ready(game, user, rules) do
    with :ok <- PlayerRules.host_check(game.players, user),
         {:ok, rules} <- Rules.check(rules, {:set_as_ready, game}),
         {:ok, players} <- Player.assign_roles(game.players)
    do
      # rules also needs to be passed to state_data...
      Map.put(game, :players, players)
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def launch_game(game, user, rules) do
    with :ok <- PlayerRules.host_check(game.players, user),
         {:ok, rules} <- Rules.check(rules, :launch)
    do
      Map.put(game, :phases, 1)
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
         {:ok, action} <- ActionRules.valid(rules, player, action),
         {:ok, player} <- Player.add_action(player, game.phases, action)
    do
      put_in(game, [:players, player.name], player)
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
    # :werewolf_win, :villager_win, otherwise
    # go to next day/night phase
    # don't need to worry about alternate paths,
    # should be same win or continue,
    # all we need to do is send the messages, let phoenix
    # handle how to broadcast the actual text
    # like:
    # {:ok, :villager_win, 'player_id'} ('player_id' is player who was killed)
    # {:ok, :werewolf_win, :user_dead}
    # {:ok, :day/:night, :user_dead/:none}
    # :user_dead could in the future be replaced by list of tuples
    # [{:user_dead, :werewolf}, {:user_dead, :vigilante}], etc
    with {:ok, target} <- Votes.count_from_actions(phase_actions(game)),
         {:ok, players, win_status} <- Player.kill_player(game.players, target),
         {:ok, rules} <- Rules.check(rules, {:end_phase, win_status})
    do
      Map.put(game, :players, players)
      # update state
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def phase_lengths() do
    [:day]
  end

  defp phase_actions(game) do
    Enum.map(game.players, fn(player) -> player.actions end)
    |> Enum.map(fn(actions) -> actions[game.phases] end)
  end
end

# 1) launch game
# 2) add players, repeat
# 3) set game as ready, assign roles
# 4) launch game, create first phase
# 5) timer till new phase begins, whilst collecting votes and actions
# 6) switch to new phase, or end game if all werewolves are gone, or werewolves equal villagers
# 7) Mark game as complete

# The timer could use Process.send_after, but that relies on the process itself being alive
# which is something we can't guarantee. Instead we will have a second gen server whose job
# it is to send the message to the game (or reboot the game if necessary) after a set time is
# complete. The message will then trigger a phase change from day to night, or vice versa.
# The timer process needs a one to one superviser as well. Every minute it will read from the
# database, or ETS store, tbd, and send a message to all games that are ready to change phase,
# count votes, and win check.

# TODO
# add gen_server functionality to game
# implement timer gen_server
# supervisors for gen_servers
# add ets backup, other db backup