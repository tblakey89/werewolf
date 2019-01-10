defmodule Werewolf.GameSupervisorTest do
  use ExUnit.Case
  alias Werewolf.{GameSupervisor, GameServer}

  describe "ensure supervisor restarts GameServer" do
    setup [:host]

    test "successfully restarts", context do
      {:ok, game} = GameSupervisor.start_game(context[:host], context[:host].id, :day)
      Werewolf.GameServer.add_player(game, %{id: 2})
      Process.exit(game, :boom)
      :timer.sleep(1)
      via = GameServer.via_tuple(context[:host].id)
      assert :sys.get_state(via).game.players[2].id == 2
      GameSupervisor.stop_game(context[:host].id)
    end
  end

  describe "when state is passed, game state is passed state" do
    setup [:host, :state_from_db]

    test "starts new game with old state", context do
      GameSupervisor.start_game(context[:host], context[:host].id, :day, context[:state_from_db])
      via = GameServer.via_tuple(context[:host].id)
      {:ok, state} = Werewolf.GameServer.add_player(via, %{id: 3})
      assert :sys.get_state(via).game.players[1].id == 1
      assert :sys.get_state(via).game.players[3].id == 3
      GameSupervisor.stop_game(context[:host].id)
    end
  end

  defp host(_context), do: [host: %{username: "test1", id: 1}]

  defp state_from_db(_context) do
    [
      state_from_db: %{
        "game" => %{
          "end_phase_unix_time" => nil,
          "id" => 178,
          "phase_length" => "day",
          "phases" => 0,
          "players" => %{
            "1" => %{
              "vote" => %{
                "actions" => %{
                  "1" => %{
                    "type" => "vote",
                    "target" => 2,
                    "option" => "none"
                  }
                }
              },
              "alive" => true,
              "host" => true,
              "id" => 1,
              "role" => "none"
            }
          }
        },
        "rules" => %{"state" => "initialized"}
      }
    ]
  end
end
