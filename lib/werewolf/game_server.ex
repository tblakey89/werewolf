defmodule Werewolf.GameServer do
  use GenServer, start: {__MODULE__, :start_link, []}, restart: :transient
  alias Werewolf.{Action, Game, Rules}

  @timeout 1000 * 60 * 60 * 24

  def start_link(user, phase_length) do
    GenServer.start_link(__MODULE__, {user, phase_length})
  end

  def init({user, phase_length}) do
    send(self(), {:set_state, user, phase_length})
    {:ok, new_state(user, phase_length)}
  end

  def add_player(game, user) do
    GenServer.call(game, {:add_player, user})
  end

  def game_ready(game, user) do
    GenServer.call(game, {:game_ready, user})
  end

  def launch_game(game, user) do
    GenServer.call(game, {:launch_game, user})
  end

  def action(game, user, target, action_type) do
    GenServer.call(game, {:action, user, target, action_type})
  end

  def end_phase(game) do
    GenServer.call(game, :end_phase)
  end

  def handle_call({:add_player, user}, _from, state_data) do
    with {:ok, game} <- Game.add_player(state_data.game, user, state_data.rules)
    do
      state_data
      |> update_game(game)
      |> reply_success(:ok)
    else
      {:error, reason} -> reply_failure(state_data, reason)
    end
  end

  def handle_call({:game_ready, user}, _from, state_data) do
    with {:ok, game, rules} <- Game.set_game_ready(state_data.game, user, state_data.rules)
    do
      state_data
      |> update_game(game)
      |> update_rules(rules)
      |> reply_success({:ok, game.players})
    else
      {:error, reason} -> reply_failure(state_data, reason)
    end
  end

  def handle_call({:launch_game, user}, _from, state_data) do
    with {:ok, game, rules} <- Game.launch_game(state_data.game, user, state_data.rules)
    do
      state_data
      |> update_game(game)
      |> update_rules(rules)
      |> reply_success(:ok)
    else
      {:error, reason} -> reply_failure(state_data, reason)
    end
  end

  def handle_call({:action, user, target, action_type}, _from, state_data) do
    with {:ok, game} <- Game.action(state_data.game, user, state_data.rules, Action.new(action_type, target))
    do
      state_data
      |> update_game(game)
      |> reply_success(:ok)
    else
      {:error, reason} -> reply_failure(state_data, reason)
    end
  end

  def handle_call(:end_phase, _from, state_data) do
    with {:ok, game, rules, target, win_status} <- Game.end_phase(state_data.game, state_data.rules)
    do
      state_data
      |> update_game(game)
      |> update_rules(rules)
      |> reply_success({win_status, target})
    else
      {:error, reason} -> reply_failure(state_data, reason)
    end
  end

  def handle_info({:set_state, user, phase_length}, _state_data) do
    state_data = new_state(user, phase_length)
    {:noreply, state_data, @timeout}
  end

  def handle_info(:timeout, state_data) do
    {:stop, {:shutdown, :timeout}, state_data}
  end

  def terminate({:shutdown, :timeout}, state_data) do
    # delete ets record if shutting down
    :ok
  end
  def terminate(_reason, _state), do: :ok

  defp new_state(user, phase_length) do
    # need to think how we can handle an invalid phase length properly
    with {:ok, game} <- Game.new(user, phase_length)
    do
      %{game: game, rules: Rules.new()}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp reply_failure(state_data, reason) do
    {:reply, {:error, reason}, state_data}
  end

  defp reply_success(state_data, reply) do
    # update ets here
    {:reply, reply, state_data, @timeout}
  end

  defp update_game(state_data, game) do
    put_in(state_data.game, game)
  end

  defp update_rules(state_data, rules) do
    put_in(state_data.rules, rules)
  end
end
