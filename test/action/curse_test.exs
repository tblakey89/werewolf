defmodule Werewolf.Action.CurseTest do
  use ExUnit.Case
  alias Werewolf.{Player, Action, KillTarget}
  import Werewolf.Support.PlayerTestSetup

  describe "resolve/4" do
    setup [:additional_player_map]

    test "when werewolf_collector targetted, successfully hunts player", context do
      players = context[:additional_player_map]

      {:ok, player} =
        Player.add_action(players["werewolf_collector"], 1, Action.new(:curse, "villager"))

      players = put_in(players["werewolf_collector"], player)

      {:ok, players, targets} =
        Action.Curse.resolve(players, 1, [KillTarget.new(:vote, "werewolf_collector")], [])

      assert players["villager"].alive == false
      assert(length(targets)) == 1
      assert(Enum.at(targets, 0).type) == :curse
      assert(Enum.at(targets, 0).target) == "villager"
    end

    test "when werewolf_collector alive, curses player, but protected", context do
      players = context[:additional_player_map]

      {:ok, player} =
        Player.add_action(players["werewolf_collector"], 1, Action.new(:curse, "villager"))

      players = put_in(players["werewolf_collector"], player)

      {:ok, players, targets} =
        Action.Curse.resolve(players, 1, [KillTarget.new(:vote, "werewolf_collector")], [
          "villager"
        ])

      assert players["villager"].alive == true
      assert(length(targets)) == 0
    end

    test "when werewolf_collector not targetted, does not resolve action", context do
      players = context[:additional_player_map]

      {:ok, player} =
        Player.add_action(players["werewolf_collector"], 1, Action.new(:curse, "villager"))

      players = put_in(players["werewolf_collector"], player)

      {:ok, players, targets} = Action.Curse.resolve(players, 1, [], [])
      assert players["villager"].alive == true
      assert(length(targets)) == 0
    end

    test "when werewolf_collector alive, but no hunt action", context do
      players = context[:additional_player_map]

      {:ok, players, targets} =
        Action.Curse.resolve(players, 1, [KillTarget.new(:vote, "werewolf_collector")], [])

      assert players["villager"].alive == true
      assert(length(targets)) == 0
    end
  end
end
