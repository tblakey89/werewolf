defmodule Werewolf.PlayerTest do
  use ExUnit.Case
  import Werewolf.Support.PlayerTestSetup
  alias Werewolf.{Player, Action}

  describe "new/2" do
    setup [:user]

    test "returns Player struct set to host when host", context do
      {:ok, player} = Player.new(:host, context[:user])
      assert player == %Player{name: context[:user].username, host: true}
    end

    test "returns Player struct set not to host when normal player", context do
      {:ok, player} = Player.new(:player, context[:user])
      assert player == %Player{name: context[:user].username, host: false}
    end
  end

  describe "assign_roles/1" do
    test "when 8 players, 2 werewolves, 6 villagers" do
      players = for n <- 1..8, do: %Player{name: "test#{n}", host: false}
      assigned_players = Map.values(Player.assign_roles(players))
      assert Enum.count(assigned_players, fn(player) -> player.role == :werewolf end) == 2
      assert Enum.count(assigned_players, fn(player) -> player.role == :villager end) == 6
    end

    test "when 18 players, 4 werewolves, 14 villagers" do
      players = for n <- 1..18, do: %Player{name: "test#{n}", host: false}
      assigned_players = Map.values(Player.assign_roles(players))
      assert Enum.count(assigned_players, fn(player) -> player.role == :werewolf end) == 4
      assert Enum.count(assigned_players, fn(player) -> player.role == :villager end) == 14
    end
  end

  describe "add_action/3" do
    setup [:regular_player]

    test "when phase number key does not exist", context do
      new_action = %Action{type: :vote, target: "user"}
      {:ok, player} = Player.add_action(context[:regular_player], "1", new_action)
      assert player.actions["1"][:vote] == new_action
    end

    test "when phase number key exists, but action type does not", context do
      player = context[:regular_player]
      player = put_in(player.actions["1"], %{})
      new_action = %Action{type: :vote, target: "user"}
      {:ok, player} = Player.add_action(player, "1", new_action)
      assert player.actions["1"][:vote] == new_action
    end

    test "when phase number key exists, and action type exists", context do
      player = context[:regular_player]
      player = put_in(player.actions["1"], %{vote: %{}})
      new_action = %Action{type: :vote, target: "user"}
      {:error, :action_already_exists} = Player.add_action(player, "1", new_action)
    end
  end

  describe "kill_player/2" do
    setup [:player_map]

    test "sets player to alive false, and calculates correct win", context do
      target = context[:player_map]["villager"]
      {:ok, players, win} = Player.kill_player(context[:player_map], target)
      assert players["villager"].alive == false
      assert win == :werewolf_win
    end

    test "not update players when no target", context do
      {:ok, players, _} = Player.kill_player(context[:player_map], :none)
      assert players == context[:player_map]
    end

    test "calculates a villager win when no more werewolves", context do
      {:ok, _, win} = Player.kill_player(context[:player_map], context[:player_map]["werewolf"])
      assert win == :village_win
    end

    test "calculates a werewolf win when no more villagers", context do
      {:ok, _, win} = Player.kill_player(context[:player_map], context[:player_map]["villager"])
      assert win == :werewolf_win
    end

    test "calculates no win when werewolf and villagers", context do
      {:ok, _, win} = Player.kill_player(context[:player_map], :none)
      assert win == :no_win
    end
  end
end
