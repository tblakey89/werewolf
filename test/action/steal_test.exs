defmodule Werewolf.Action.StealTest do
  use ExUnit.Case
  alias Werewolf.{Player, Action}
  import Werewolf.Support.PlayerTestSetup

  describe "resolve/2" do
    setup [:additional_player_map]

    test "when werewolf_thief alive, successfully steals from player", context do
      players = context[:additional_player_map]

      {:ok, player} =
        Player.add_action(players["werewolf_thief"], 1, Action.new(:steal, "detective"))

      players = put_in(players["werewolf_thief"], player)

      {:ok, players} = Action.Steal.resolve(players, 1)
      assert players["detective"].actions[1][:theft].type == :theft
      assert players["detective"].actions[1][:theft].result == :magnifying_glass
      assert players["werewolf_thief"].actions[1][:steal].result == :magnifying_glass
      assert length(players["detective"].items) == 0
      assert length(players["werewolf_thief"].items) == 2
    end

    test "when werewolf_thief alive, successfully steals from player with action, item used",
         context do
      players = context[:additional_player_map]

      {:ok, player} =
        Player.add_action(players["werewolf_thief"], 1, Action.new(:steal, "werewolf_saboteur"))

      players = put_in(players["werewolf_thief"], player)

      {:ok, saboteur_player} =
        Player.add_action(players["werewolf_saboteur"], 1, Action.new(:sabotage, "detective"))

      players = put_in(players["werewolf_saboteur"], saboteur_player)

      assert Enum.at(players["werewolf_saboteur"].items, 0).remaining_uses == 1
      {:ok, players} = Action.Steal.resolve(players, 1)
      assert players["werewolf_saboteur"].actions[1][:theft].type == :theft
      assert players["werewolf_saboteur"].actions[1][:theft].result == :hammer
      assert players["werewolf_thief"].actions[1][:steal].result == :hammer
      assert length(players["werewolf_saboteur"].items) == 0
      assert length(players["werewolf_thief"].items) == 2
      assert Enum.at(players["werewolf_thief"].items, 0).remaining_uses == 0
    end

    test "when werewolf_thief alive, successfully steals from player with multiple items",
         context do
      players = context[:additional_player_map]
      {:ok, player} = Player.add_action(players["werewolf_thief"], 1, Action.new(:steal, "witch"))
      players = put_in(players["werewolf_thief"], player)

      {:ok, players} = Action.Steal.resolve(players, 1)
      assert players["witch"].actions[1][:theft].type == :theft
      assert length(players["witch"].items) == 1
      assert length(players["werewolf_thief"].items) == 2
    end

    test "when werewolf_thief alive, successfully steals nothing from villager", context do
      players = context[:additional_player_map]

      {:ok, player} =
        Player.add_action(players["werewolf_thief"], 1, Action.new(:steal, "villager"))

      players = put_in(players["werewolf_thief"], player)

      {:ok, players} = Action.Steal.resolve(players, 1)
      assert players["villager"].actions[1][:theft] == nil
      assert players["werewolf_thief"].actions[1][:steal].result == nil
      assert length(players["werewolf_thief"].items) == 1
    end
  end
end
