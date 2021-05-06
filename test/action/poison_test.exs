defmodule Werewolf.Action.PoisonTest do
  use ExUnit.Case
  alias Werewolf.{Player, Action, KillTarget}
  import Werewolf.Support.PlayerTestSetup

  describe "resolve/4" do
    setup [:additional_player_map]

    test "when witch alive, successfully poisons player", context do
      players = context[:additional_player_map]
      {:ok, player} = Player.add_action(players["witch"], 1, Action.new(:poison, "villager"))
      players = put_in(players["witch"], player)

      {:ok, players, targets} = Action.Poison.resolve(players, 1, [], [])
      assert players["villager"].alive == false
      assert(length(targets)) == 1
      assert(Enum.at(targets, 0).type) == :poison
      assert(Enum.at(targets, 0).target) == "villager"
    end

    test "when witch alive, poisons player, but protected", context do
      players = context[:additional_player_map]
      {:ok, player} = Player.add_action(players["witch"], 1, Action.new(:poison, "villager"))
      players = put_in(players["witch"], player)

      {:ok, players, targets} = Action.Poison.resolve(players, 1, [], ["villager"])
      assert players["villager"].alive == true
      assert(length(targets)) == 0
    end

    test "when witch alive, but no poison action", context do
      players = context[:additional_player_map]
      {:ok, players, targets} = Action.Poison.resolve(players, 1, [], [])
      assert players["villager"].alive == true
      assert(length(targets)) == 0
    end
  end
end
