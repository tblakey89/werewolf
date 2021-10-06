defmodule Werewolf.Action.StrangleTest do
  use ExUnit.Case
  alias Werewolf.{Player, Action, KillTarget}
  import Werewolf.Support.PlayerTestSetup

  describe "resolve/4" do
    setup [:additional_player_map]

    test "when serial_killer alive, successfully strangles player", context do
      players = context[:additional_player_map]

      {:ok, player} =
        Player.add_action(players["serial_killer"], 1, Action.new(:strangle, "villager"))

      players = put_in(players["serial_killer"], player)

      {:ok, players, targets} = Action.Strangle.resolve(players, 1, [], [])
      assert players["villager"].alive == false
      assert(length(targets)) == 1
      assert(Enum.at(targets, 0).type) == :strangle
      assert(Enum.at(targets, 0).target) == "villager"
    end

    test "when serial_killer alive, strangles player, but protected", context do
      players = context[:additional_player_map]

      {:ok, player} =
        Player.add_action(players["serial_killer"], 1, Action.new(:strangle, "villager"))

      players = put_in(players["serial_killer"], player)

      {:ok, players, targets} = Action.Strangle.resolve(players, 1, [], ["villager"])
      assert players["villager"].alive == true
      assert(length(targets)) == 0
    end

    test "when serial_killer alive, but no strangle action", context do
      players = context[:additional_player_map]
      {:ok, players, targets} = Action.Strangle.resolve(players, 1, [], [])
      assert players["villager"].alive == true
      assert(length(targets)) == 0
    end
  end
end
