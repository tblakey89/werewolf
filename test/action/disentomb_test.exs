defmodule Werewolf.Action.DisentombTest do
  use ExUnit.Case
  alias Werewolf.{Player, Action}
  import Werewolf.Support.PlayerTestSetup

  describe "resolve/2" do
    setup [:additional_player_map]

    test "when gravedigger alive, successfully disentombs from dead player", context do
      players = context[:additional_player_map]

      {:ok, player} =
        Player.add_action(players["gravedigger"], 1, Action.new(:disentomb, "detective"))

      players = put_in(players["gravedigger"], player)
      players = put_in(players["detective"].alive, false)

      {:ok, players} = Action.Disentomb.resolve(players, 1)
      assert players["detective"].actions[1][:grave_rob].type == :grave_rob
      assert players["detective"].actions[1][:grave_rob].result == :magnifying_glass
      assert players["gravedigger"].actions[1][:disentomb].result == :magnifying_glass
      assert length(players["detective"].items) == 0
      assert length(players["gravedigger"].items) == 2
    end

    test "when gravedigger alive, successfully disentombs from player with multiple items",
         context do
      players = context[:additional_player_map]

      {:ok, player} =
        Player.add_action(players["gravedigger"], 1, Action.new(:disentomb, "witch"))

      players = put_in(players["gravedigger"], player)
      players = put_in(players["witch"].alive, false)

      {:ok, players} = Action.Disentomb.resolve(players, 1)
      assert players["witch"].actions[1][:grave_rob].type == :grave_rob
      assert length(players["witch"].items) == 1
      assert length(players["gravedigger"].items) == 2
    end

    test "when gravedigger alive, successfully disentombs nothing from villager", context do
      players = context[:additional_player_map]

      {:ok, player} =
        Player.add_action(players["gravedigger"], 1, Action.new(:disentomb, "villager"))

      players = put_in(players["gravedigger"], player)
      players = put_in(players["villager"].alive, false)

      {:ok, players} = Action.Disentomb.resolve(players, 1)
      assert players["villager"].actions[1][:grave_rob] == nil
      assert players["gravedigger"].actions[1][:disentomb].result == nil
      assert length(players["gravedigger"].items) == 1
    end

    test "when gravedigger alive, unsuccessfully disentombs from dead player", context do
      players = context[:additional_player_map]

      {:ok, player} =
        Player.add_action(players["gravedigger"], 1, Action.new(:disentomb, "detective"))

      players = put_in(players["gravedigger"], player)

      {:ok, players} = Action.Disentomb.resolve(players, 1)
      assert players["detective"].actions[1][:grave_rob] == nil
      assert players["gravedigger"].actions[1][:disentomb].result == nil
      assert length(players["detective"].items) == 1
      assert length(players["gravedigger"].items) == 1
    end
  end
end
