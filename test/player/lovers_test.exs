defmodule Werewolf.Player.LoversTest do
  use ExUnit.Case
  import Werewolf.Support.PlayerTestSetup
  alias Werewolf.Player.Lovers
  alias Werewolf.Options
  alias Werewolf.Player

  describe "assign/2" do
    setup [:player_map]

    test "returns two lovers when option enabled", context do
      players = Lovers.assign(context[:player_map], %Options{allow_lovers: true})
      assert Enum.count(players, fn {id, player} -> player.lover end) == 2
    end

    test "returns two lovers when option disabled", context do
      players = Lovers.assign(context[:player_map], %Options{allow_lovers: false})
      assert Enum.count(players, fn {id, player} -> player.lover end) == 0
    end

    test "returns the same two players when other players not allowed to be lovers" do
      players = %{
        "villager" => %Player{
          id: "villager",
          host: false,
          role: :villager,
          team: :villager
        },
        "werewolf" => %Player{
          id: "werewolf",
          host: false,
          role: :werewolf,
          team: :werewolf
        },
        "devil" => %Player{
          id: "devil",
          host: false,
          role: :devil,
          team: :werewolf_aux
        },
        "fool" => %Player{
          id: "fool",
          host: false,
          role: :fool,
          team: :fool
        }
      }

      players = Lovers.assign(players, %Options{allow_lovers: true})
      assert players["villager"].lover
      assert players["werewolf"].lover
      assert !players["devil"].lover
      assert !players["fool"].lover
    end

    test "returns the same villager and detective as lovers" do
      players = %{
        "villager" => %Player{
          id: "villager",
          host: false,
          role: :villager,
          team: :villager
        },
        "detective" => %Player{
          id: "detective",
          host: false,
          role: :detective,
          team: :villager
        }
      }

      players = Lovers.assign(players, %Options{allow_lovers: true})
      assert players["villager"].lover
      assert players["detective"].lover
    end
  end
end
