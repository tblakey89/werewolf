defmodule Werewolf.PlayerTest do
  use ExUnit.Case
  import Werewolf.Support.PlayerTestSetup
  alias Werewolf.{Player, Action}

  describe "new/2" do
    setup [:user]

    test "returns Player struct set to host when host", context do
      {:ok, player} = Player.new(:host, context[:user])
      assert player == %Player{id: context[:user].id, host: true}
    end

    test "returns Player struct set not to host when normal player", context do
      {:ok, player} = Player.new(:player, context[:user])
      assert player == %Player{id: context[:user].id, host: false}
    end
  end

  describe "assign_roles/1" do
    test "when 8 players, 2 werewolves, 6 villagers" do
      assigned_players = Map.values(Player.assign_roles(generate_players(8)))
      assert Enum.count(assigned_players, fn player -> player.role == :werewolf end) == 2
      assert Enum.count(assigned_players, fn player -> player.role == :villager end) == 6
    end

    test "when 18 players, 4 werewolves, 14 villagers" do
      assigned_players = Map.values(Player.assign_roles(generate_players(18)))
      assert Enum.count(assigned_players, fn player -> player.role == :werewolf end) == 4
      assert Enum.count(assigned_players, fn player -> player.role == :villager end) == 14
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
      {:ok, players, win} = Player.kill_player(context[:player_map], "villager")
      assert players["villager"].alive == false
      assert win == :werewolf_win
    end

    test "not update players when no target", context do
      {:ok, players, _} = Player.kill_player(context[:player_map], :none)
      assert players == context[:player_map]
    end

    test "calculates a villager win when no more werewolves", context do
      {:ok, _, win} = Player.kill_player(context[:player_map], "werewolf")
      assert win == :village_win
    end

    test "calculates a werewolf win when no more villagers", context do
      {:ok, _, win} = Player.kill_player(context[:player_map], "villager")
      assert win == :werewolf_win
    end

    test "calculates no win when werewolf and villagers", context do
      {:ok, _, win} = Player.kill_player(context[:player_map], :none)
      assert win == :no_win
    end
  end

  defp generate_players(player_number) do
    Enum.reduce(
      for(n <- 1..player_number, do: %Player{id: "test#{n}", host: false}),
      %{},
      fn player, acc ->
        put_in(acc[player.id], player)
      end
    )
  end
end
