defmodule Werewolf.Action.BiteTest do
  use ExUnit.Case
  alias Werewolf.{Player, Action, KillTarget}
  import Werewolf.Support.PlayerTestSetup

  describe "resolve/4" do
    setup [:additional_player_map]

    test "when werewolf_alpha alive, successfully bites villager player", context do
      players = context[:additional_player_map]

      {:ok, player} =
        Player.add_action(players["werewolf_alpha"], 1, Action.new(:bite, "villager"))

      players = put_in(players["werewolf_alpha"], player)

      {:ok, players, targets} = Action.Bite.resolve(players, 1, [], [])
      assert players["villager"].alive == true
      assert players["villager"].role == :werewolf
      assert players["villager"].team == :werewolf
      assert players["villager"].win_condition == :werewolf_win
      assert(length(targets)) == 1
      assert(Enum.at(targets, 0).type) == :new_werewolf
      assert(Enum.at(targets, 0).target) == "villager"
    end

    test "when werewolf_alpha alive, successfully bites devil player", context do
      players = context[:additional_player_map]
      {:ok, player} = Player.add_action(players["werewolf_alpha"], 1, Action.new(:bite, "devil"))
      players = put_in(players["werewolf_alpha"], player)

      {:ok, players, targets} = Action.Bite.resolve(players, 1, [], [])
      assert players["devil"].alive == true
      assert players["devil"].role == :werewolf
      assert players["devil"].team == :werewolf
      assert players["devil"].win_condition == :werewolf_win
      assert(length(targets)) == 1
      assert(Enum.at(targets, 0).type) == :new_werewolf
      assert(Enum.at(targets, 0).target) == "devil"
    end

    test "when werewolf_alpha alive, successfully bites fool player", context do
      players = context[:additional_player_map]
      {:ok, player} = Player.add_action(players["werewolf_alpha"], 1, Action.new(:bite, "fool"))
      players = put_in(players["werewolf_alpha"], player)

      {:ok, players, targets} = Action.Bite.resolve(players, 1, [], [])
      assert players["fool"].alive == false
      assert players["fool"].role == :fool
      assert players["fool"].team == :fool
      assert players["fool"].win_condition == :fool_win
      assert(length(targets)) == 1
      assert(Enum.at(targets, 0).type) == :lycan_bite
      assert(Enum.at(targets, 0).target) == "fool"
    end

    test "when werewolf_alpha alive, bites player, but protected", context do
      players = context[:additional_player_map]

      {:ok, player} =
        Player.add_action(players["werewolf_alpha"], 1, Action.new(:bite, "villager"))

      players = put_in(players["werewolf_alpha"], player)

      {:ok, players, targets} = Action.Bite.resolve(players, 1, [], ["villager"])
      assert players["villager"].alive == true
      assert players["villager"].role == :villager
      assert(length(targets)) == 0
    end

    test "when werewolf_alpha alive, but no bite action", context do
      players = context[:additional_player_map]
      {:ok, players, targets} = Action.Bite.resolve(players, 1, [], [])
      assert players["villager"].alive == true
      assert(length(targets)) == 0
    end
  end
end
