defmodule Werewolf.GameSupervisor do
  alias Werewolf.GameServer
  use Supervisor

  def init(:ok) do
    Supervisor.init([GameServer], strategy: :simple_one_for_one)
  end

  def start_link(_options) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def start_game(user, phase_length) do
    Supervisor.start_child(__MODULE__, [user, phase_length])
  end

  def stop_game(user) do
    :ets.delete(:game_state, user.id)
    Supervisor.terminate_child(__MODULE__, pid_from_id(user.id))
  end

  defp pid_from_id(id) do
    id
    |> GameServer.via_tuple()
    |> GenServer.whereis()
  end
end
