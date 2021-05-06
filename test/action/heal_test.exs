defmodule Werewolf.Action.HealTest do
  use ExUnit.Case
  alias Werewolf.{Player, Action}
  import Werewolf.Support.PlayerTestSetup

  describe "resolve/2" do
    setup [:player_map]

    test "when doctor alive, successfully heals player", context do
      players = context[:player_map]
      {:ok, player} = Player.add_action(players["doctor"], 1, Action.new(:heal, "villager"))
      players = put_in(players["doctor"], player)

      {:ok, heal_targets} = Action.Heal.resolve(players, 1)
      assert heal_targets == ["villager"]
    end

    test "when doctor alive, but no heal action", context do
      players = context[:player_map]
      {:ok, heal_targets} = Action.Heal.resolve(players, 1)
      assert heal_targets == []
    end

    test "when heal action, but wrong item", context do
      players = context[:player_map]
      {:ok, player} = Player.add_action(players["detective"], 1, Action.new(:heal, "villager"))
      players = put_in(players["detective"], player)

      {:ok, heal_targets} = Action.Heal.resolve(players, 1)
      assert heal_targets == []
    end
  end
end
