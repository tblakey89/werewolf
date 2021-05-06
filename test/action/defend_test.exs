defmodule Werewolf.Action.DefendTest do
  use ExUnit.Case
  alias Werewolf.{Player, Action}
  import Werewolf.Support.PlayerTestSetup

  describe "resolve/2" do
    setup [:additional_player_map]

    test "when lawyer alive, successfully defends player", context do
      players = context[:additional_player_map]
      {:ok, player} = Player.add_action(players["lawyer"], 1, Action.new(:defend, "villager"))
      players = put_in(players["lawyer"], player)

      {:ok, defend_targets} = Action.Defend.resolve(players, 1)
      assert defend_targets == ["villager"]
    end

    test "when lawyer alive, but no defend action", context do
      players = context[:additional_player_map]
      {:ok, defend_targets} = Action.Defend.resolve(players, 1)
      assert defend_targets == []
    end

    test "when defend action, but wrong item", context do
      players = context[:additional_player_map]
      {:ok, player} = Player.add_action(players["detective"], 1, Action.new(:defend, "villager"))
      players = put_in(players["detective"], player)

      {:ok, defend_targets} = Action.Defend.resolve(players, 1)
      assert defend_targets == []
    end
  end
end
