defmodule Werewolf.Action.HuntTest do
  use ExUnit.Case
  alias Werewolf.{Player, Action, KillTarget}
  import Werewolf.Support.PlayerTestSetup

  describe "resolve/4" do
    setup [:additional_player_map]

    test "when hunter targetted, successfully hunts player", context do
      players = context[:additional_player_map]
      {:ok, player} = Player.add_action(players["hunter"], 1, Action.new(:hunt, "villager"))
      players = put_in(players["hunter"], player)

      {:ok, players, targets} =
        Action.Hunt.resolve(players, 1, [KillTarget.new(:vote, "hunter")], [])

      assert players["villager"].alive == false
      assert(length(targets)) == 1
      assert(Enum.at(targets, 0).type) == :hunt
      assert(Enum.at(targets, 0).target) == "villager"
    end

    test "when hunter alive, hunts player, but protected", context do
      players = context[:additional_player_map]
      {:ok, player} = Player.add_action(players["hunter"], 1, Action.new(:hunt, "villager"))
      players = put_in(players["hunter"], player)

      {:ok, players, targets} =
        Action.Hunt.resolve(players, 1, [KillTarget.new(:vote, "hunter")], ["villager"])

      assert players["villager"].alive == true
      assert(length(targets)) == 0
    end

    test "when hunter not targetted, does not resolve action", context do
      players = context[:additional_player_map]
      {:ok, player} = Player.add_action(players["hunter"], 1, Action.new(:hunt, "villager"))
      players = put_in(players["hunter"], player)

      {:ok, players, targets} = Action.Hunt.resolve(players, 1, [], [])
      assert players["villager"].alive == true
      assert(length(targets)) == 0
    end

    test "when hunter alive, but no hunt action", context do
      players = context[:additional_player_map]

      {:ok, players, targets} =
        Action.Hunt.resolve(players, 1, [KillTarget.new(:vote, "hunter")], [])

      assert players["villager"].alive == true
      assert(length(targets)) == 0
    end
  end
end
