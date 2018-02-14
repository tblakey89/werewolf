defmodule Werewolf.GameSupervisorTest do
  use ExUnit.Case
  alias Werewolf.{GameSupervisor, GameServer}

  describe "ensure supervisor restarts GameServer" do
    setup [:host]
    test "successfully restarts", context do
      {:ok, game} = GameSupervisor.start_game(context[:host], :day)
      Werewolf.GameServer.add_player(game, %{id: "test2"})
      Process.exit(game, :boom)
      :timer.sleep(1)
      via = GameServer.via_tuple(context[:host].id)
      assert :sys.get_state(via).game.players["test2"].id == "test2"
    end
  end

  defp host(_context), do: [host: %{username: "test1", id: "test1"}]
end
