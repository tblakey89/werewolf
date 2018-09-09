defmodule Werewolf.GameSupervisor do
  alias Werewolf.GameServer
  use Supervisor

  def init(:ok) do
    Supervisor.init([GameServer], strategy: :simple_one_for_one)
  end

  def start_link(_options) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def start_game(user, name, phase_length, state \\ nil) do
    Supervisor.start_child(__MODULE__, [user, name, phase_length, state])
  end

  def stop_game(name) do
    # need to confirm is host
    :ets.delete(:game_state, name)
    Supervisor.terminate_child(__MODULE__, pid_from_name(name))
  end

  def pid_from_name(name) do
    name
    |> GameServer.via_tuple()
    |> GenServer.whereis()
  end
end
