defmodule Werewolf.Player.LycanCurseTest do
  use ExUnit.Case
  import Werewolf.Support.PlayerTestSetup
  alias Werewolf.Player.LycanCurse
  alias Werewolf.Options
  alias Werewolf.Player

  describe "assign/2" do
    setup [:player_map]

    test "werewolf_aux can have lycan_curse" do
      players = %{
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
        }
      }

      players = LycanCurse.assign(players, %Options{allow_lycan_curse: true})
      assert players["devil"].lycan_curse
      assert !players["werewolf"].lycan_curse
    end

    test "villagers can have lycan_curse" do
      players = %{
        "werewolf" => %Player{
          id: "werewolf",
          host: false,
          role: :werewolf,
          team: :werewolf
        },
        "villager" => %Player{
          id: "villager",
          host: false,
          role: :villager,
          team: :villager
        }
      }

      players = LycanCurse.assign(players, %Options{allow_lycan_curse: true})
      assert players["villager"].lycan_curse
      assert !players["werewolf"].lycan_curse
    end

    test "lovers cant have lycan_curse" do
      players = %{
        "villager" => %Player{
          id: "villager",
          host: false,
          role: :villager,
          team: :villager,
          lover: true
        }
      }

      players = LycanCurse.assign(players, %Options{allow_lycan_curse: true})
      assert !players["villager"].lycan_curse
    end

    test "villagers can't have lycan_curse when option disabled" do
      players = %{
        "werewolf" => %Player{
          id: "werewolf",
          host: false,
          role: :werewolf,
          team: :werewolf
        },
        "villager" => %Player{
          id: "villager",
          host: false,
          role: :villager,
          team: :villager
        }
      }

      players = LycanCurse.assign(players, %Options{allow_lycan_curse: false})
      assert !players["villager"].lycan_curse
      assert !players["werewolf"].lycan_curse
    end
  end
end
