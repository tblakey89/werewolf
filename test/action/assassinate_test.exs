defmodule Werewolf.Action.AssassinateTest do
  use ExUnit.Case
  alias Werewolf.{Player, Action, KillTarget}
  import Werewolf.Support.PlayerTestSetup

  describe "resolve/4" do
    setup [:additional_player_map]

    test "when ninja alive, successfully assassinates player", context do
      players = context[:additional_player_map]
      {:ok, player} = Player.add_action(players["ninja"], 1, Action.new(:assassinate, "werewolf"))
      players = put_in(players["ninja"], player)

      {:ok, players, targets} = Action.Assassinate.resolve(players, 1, [], [])
      assert players["werewolf"].alive == false
      assert(length(targets)) == 1
      assert(Enum.at(targets, 0).type) == :assassinate
      assert(Enum.at(targets, 0).target) == "werewolf"
    end

    test "when ninja alive, assassinates player, but protected", context do
      players = context[:additional_player_map]
      {:ok, player} = Player.add_action(players["ninja"], 1, Action.new(:assassinate, "villager"))
      players = put_in(players["ninja"], player)

      {:ok, players, targets} = Action.Assassinate.resolve(players, 1, [], ["villager"])
      assert players["villager"].alive == true
      assert(length(targets)) == 0
    end

    test "when ninja alive, assassinates player, but target dead", context do
      players = context[:additional_player_map]
      {:ok, player} = Player.add_action(players["ninja"], 1, Action.new(:assassinate, "villager"))
      players = put_in(players["villager"].alive, false)
      players = put_in(players["ninja"], player)

      {:ok, players, targets} = Action.Assassinate.resolve(players, 1, [], ["villager"])
      assert players["villager"].alive == false
      assert(length(targets)) == 0
    end

    test "when ninja alive, successfully assassinates player, but commits seppuku", context do
      players = context[:additional_player_map]
      {:ok, player} = Player.add_action(players["ninja"], 1, Action.new(:assassinate, "villager"))
      players = put_in(players["ninja"], player)

      {:ok, players, targets} =
        Action.Assassinate.resolve(players, 1, [KillTarget.new(:poison, "werewolf")], [])

      assert players["villager"].alive == false
      assert players["ninja"].alive == false
      assert length(targets) == 3
      assert Enum.at(targets, 0).type == :poison
      assert Enum.at(targets, 0).target == "werewolf"
      assert Enum.at(targets, 1).type == :assassinate
      assert Enum.at(targets, 1).target == "villager"
      assert Enum.at(targets, 2).type == :seppuku
      assert Enum.at(targets, 2).target == "ninja"
    end

    test "when ninja has died, successfully assassinates player, but does not commit seppuku",
         context do
      players = context[:additional_player_map]
      {:ok, player} = Player.add_action(players["ninja"], 1, Action.new(:assassinate, "villager"))
      player = put_in(player.alive, false)
      players = put_in(players["ninja"], player)

      {:ok, players, targets} = Action.Assassinate.resolve(players, 1, [], [])

      assert players["villager"].alive == false
      assert players["ninja"].alive == false
      assert length(targets) == 1
      assert Enum.at(targets, 0).type == :assassinate
      assert Enum.at(targets, 0).target == "villager"
    end

    test "when ninja alive, but no assassinate action", context do
      players = context[:additional_player_map]
      {:ok, players, targets} = Action.Assassinate.resolve(players, 1, [], [])
      assert players["villager"].alive == true
      assert(length(targets)) == 0
    end
  end
end
