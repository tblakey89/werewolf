defmodule Werewolf.GameServer do
  use GenServer, start: {__MODULE__, :start_link, []}, restart: :transient
  alias Werewolf.{Action, Game, Rules, Phase}

  @timeout 1000 * 60 * 60 * 24

  def start_link(user, name, phase_length, state, broadcast_func) do
    GenServer.start_link(
      __MODULE__,
      {user, name, phase_length, state, broadcast_func},
      name: via_tuple(name)
    )
  end

  def init({user, name, phase_length, state, broadcast_func}) do
    send(self(), {:set_state, user, name, phase_length, state, broadcast_func})
    {:ok, state || new_state(user, name, phase_length)}
  end

  def get_state(game) do
    GenServer.call(game, :get_state)
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

  def stop(game) do
    GenServer.stop(game)
  end

  def handle_call(:get_state, _from, state_data) do
    {:reply, {:ok, state_data}, state_data, @timeout}
  end

  def handle_call({:add_player, user}, _from, state_data) do
    with {:ok, game, rules} <- Game.add_player(state_data.game, user, state_data.rules) do
      state_data
      |> update_game(game)
      |> update_rules(rules)
      |> reply_success({:ok, :add_player, user})
    else
      {:error, reason} -> reply_failure(state_data, reason)
    end
  end

  def handle_call({:launch_game, user}, _from, state_data) do
    with {:ok, game, rules} <- Game.launch_game(state_data.game, user, state_data.rules) do
      state_data
      |> update_game(game)
      |> update_rules(rules)
      |> update_timer(start_phase_countdown(game, rules))
      |> reply_success({:ok, :launch_game})
    else
      {:error, reason} -> reply_failure(state_data, reason)
    end
  end

  def handle_call({:action, user, target, action_type}, _from, state_data) do
    with {:ok, game} <-
           Game.action(state_data.game, user, state_data.rules, Action.new(action_type, target)) do
      state_data
      |> update_game(game)
      |> reply_success(
        {:ok, :action, state_data.rules.state, action_type, user, target,
         Game.current_vote_count(game)}
      )
    else
      {:error, reason} -> reply_failure(state_data, reason)
    end
  end

  def handle_call(:end_phase, _from, state_data) do
    cancel_phase_countdown(state_data.timer)
    trigger_end_phase(state_data, &reply_success/2)
  end

  def handle_info(:end_phase, state_data) do
    # will have to broadcast to all users both in handle info, as no from
    # to pass messages back to the channel
    trigger_end_phase(state_data, &noreply_success/2)
  end

  def handle_info({:set_state, user, name, phase_length, state, broadcast_func}, _state_data) do
    state_data =
      case :ets.lookup(:game_state, name) do
        [] ->
          (Werewolf.GameFromBackup.convert(state) || new_state(user, name, phase_length))
          |> Map.put(:broadcast_func, broadcast_func)
          |> set_timer()

        [{_key, state}] ->
          state
      end

    :ets.insert(:game_state, {name, state_data})
    {:noreply, state_data, @timeout}
  end

  def handle_info(:timeout, state_data) do
    {:stop, {:shutdown, :timeout}, state_data}
  end

  def terminate({:shutdown, :timeout}, state_data) do
    :ets.delete(:game_state, state_data.game.id)
    :ok
  end

  def terminate(_reason, _state), do: :ok

  def via_tuple(name), do: {:via, Registry, {Registry.GameServer, name}}

  def whereis_name(name) do
    GenServer.call(:registry, {:whereis_name, name})
  end

  defp trigger_end_phase(state_data, success_fn) do
    with {:ok, game, rules, target, win_status} <-
           Game.end_phase(state_data.game, state_data.rules) do
      state_data
      |> update_game(game)
      |> update_rules(rules)
      |> update_timer(start_phase_countdown(game, rules))
      |> success_fn.({win_status, target, game.phases})
    else
      {:error, reason} -> reply_failure(state_data, reason)
    end
  end

  defp start_phase_countdown(game, %Rules{state: state})
       when state == :day_phase or state == :night_phase do
    Process.send_after(
      self(),
      :end_phase,
      Phase.milliseconds_till_end_of_phase(game.end_phase_unix_time)
    )
  end

  defp start_phase_countdown(_, _), do: nil

  defp cancel_phase_countdown(nil), do: nil
  defp cancel_phase_countdown(timer), do: Process.cancel_timer(timer)

  defp new_state(user, name, phase_length) do
    # need to think how we can handle an invalid phase length properly
    with {:ok, game} <- Game.new(user, name, phase_length) do
      %{game: game, rules: Rules.new()}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp noreply_success(state_data, reply) do
    state_data.broadcast_func.(state_data, reply)
    {:noreply, state_data, @timeout}
  end

  defp reply_failure(state_data, reason) do
    {:reply, {:error, reason}, state_data}
  end

  defp reply_success(state_data, reply) do
    :ets.insert(:game_state, {state_data.game.id, state_data})
    state_data.broadcast_func.(state_data, reply)
    {:reply, Tuple.append(reply, state_data), state_data, @timeout}
  end

  defp update_game(state_data, game) do
    put_in(state_data.game, game)
  end

  defp update_rules(state_data, rules) do
    put_in(state_data.rules, rules)
  end

  defp update_timer(state_data, timer) do
    put_in(state_data, [:timer], timer)
  end

  defp set_timer(state_data) do
    Map.put(state_data, :timer, start_phase_countdown(state_data.game, state_data.rules))
  end
end
