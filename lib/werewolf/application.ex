defmodule Werewolf.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: Werewolf.Worker.start_link(arg)
      # {Werewolf.Worker, arg},
      {Registry, keys: :unique, name: Registry.GameServer},
      Werewolf.GameSupervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    :ets.new(:game_state, [:public, :named_table])
    opts = [strategy: :one_for_one, name: Werewolf.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
