defmodule Werewolf.Action.SabotageTest do
  use ExUnit.Case
  alias Werewolf.{Player, Action}
  import Werewolf.Support.PlayerTestSetup

  describe "resolve/2" do
    setup [:additional_player_map]

    test "when werewolf_saboteur alive, successfully sabotages from player", context do
      players = context[:additional_player_map]

      {:ok, player} =
        Player.add_action(players["werewolf_saboteur"], 1, Action.new(:sabotage, "detective"))

      players = put_in(players["werewolf_saboteur"], player)

      {:ok, players} = Action.Sabotage.resolve(players, 1)
      assert players["detective"].actions[1][:destroyed].type == :destroyed
      assert players["detective"].actions[1][:destroyed].result == :magnifying_glass
      assert players["werewolf_saboteur"].actions[1][:sabotage].result == :magnifying_glass
      assert length(players["detective"].items) == 0
    end

    test "when werewolf_saboteur alive, successfully sabotages from player with multiple items",
         context do
      players = context[:additional_player_map]

      {:ok, player} =
        Player.add_action(players["werewolf_saboteur"], 1, Action.new(:sabotage, "witch"))

      players = put_in(players["werewolf_saboteur"], player)

      {:ok, players} = Action.Sabotage.resolve(players, 1)
      assert players["witch"].actions[1][:destroyed].type == :destroyed
      assert length(players["witch"].items) == 1
    end

    test "when werewolf_saboteur alive, successfully sabotages nothing from villager", context do
      players = context[:additional_player_map]

      {:ok, player} =
        Player.add_action(players["werewolf_saboteur"], 1, Action.new(:sabotage, "villager"))

      players = put_in(players["werewolf_saboteur"], player)

      {:ok, players} = Action.Sabotage.resolve(players, 1)
      assert players["villager"].actions[1][:destroyed] == nil
      assert players["werewolf_saboteur"].actions[1][:sabotage].result == nil
    end
  end
end
