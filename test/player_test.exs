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
    test "when 8 players" do
      assigned_players = Map.values(Player.assign_roles(generate_players(8), []))
      assert Enum.count(assigned_players, fn player -> player.role == :werewolf end) == 2
      assert Enum.count(assigned_players, fn player -> player.role == :villager end) == 6
      assert Enum.count(assigned_players, fn player -> player.role == :detective end) == 0
      assert Enum.count(assigned_players, fn player -> player.role == :doctor end) == 0
    end

    test "when 2 players, doctor, detective included" do
      assigned_players =
        Map.values(Player.assign_roles(generate_players(2), [:doctor, :detective]))

      assert Enum.count(assigned_players, fn player -> player.role == :werewolf end) == 1
      assert Enum.count(assigned_players, fn player -> player.role == :villager end) == 0

      assert Enum.count(assigned_players, fn player ->
               player.role == :detective || player.role == :doctor
             end) == 1
    end

    test "when 8 players, doctor, detective included" do
      assigned_players =
        Map.values(Player.assign_roles(generate_players(8), [:doctor, :detective]))

      assert Enum.count(assigned_players, fn player -> player.role == :werewolf end) == 2
      assert Enum.count(assigned_players, fn player -> player.role == :villager end) == 4
      assert Enum.count(assigned_players, fn player -> player.role == :detective end) == 1
      assert Enum.count(assigned_players, fn player -> player.role == :doctor end) == 1
    end

    test "when 8 players, mason included" do
      assigned_players = Map.values(Player.assign_roles(generate_players(8), [:mason]))

      assert Enum.count(assigned_players, fn player -> player.role == :werewolf end) == 2
      assert Enum.count(assigned_players, fn player -> player.role == :villager end) == 4
      assert Enum.count(assigned_players, fn player -> player.role == :mason end) == 2
    end

    test "when 18 players, 4 werewolves, 14 villagers" do
      assigned_players =
        Map.values(Player.assign_roles(generate_players(18), [:doctor, :detective]))

      assert Enum.count(assigned_players, fn player -> player.role == :werewolf end) == 4
      assert Enum.count(assigned_players, fn player -> player.role == :villager end) == 12
      assert Enum.count(assigned_players, fn player -> player.role == :detective end) == 1
      assert Enum.count(assigned_players, fn player -> player.role == :doctor end) == 1
    end

    test "when 18 players, 4 werewolves, all additional roles" do
      assigned_players =
        Map.values(
          Player.assign_roles(generate_players(18), [
            :doctor,
            :detective,
            :mason,
            :little_girl,
            :devil,
            :hunter,
            :fool
          ])
        )

      assert Enum.count(assigned_players, fn player -> player.role == :werewolf end) == 4
      assert Enum.count(assigned_players, fn player -> player.role == :villager end) == 6
      assert Enum.count(assigned_players, fn player -> player.role == :detective end) == 1
      assert Enum.count(assigned_players, fn player -> player.role == :doctor end) == 1
      assert Enum.count(assigned_players, fn player -> player.role == :mason end) == 2
      assert Enum.count(assigned_players, fn player -> player.role == :little_girl end) == 1
      assert Enum.count(assigned_players, fn player -> player.role == :devil end) == 1
      assert Enum.count(assigned_players, fn player -> player.role == :hunter end) == 1
      assert Enum.count(assigned_players, fn player -> player.role == :fool end) == 1
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
      assert player.actions["1"][:vote] == %{}
      {:ok, player} = Player.add_action(player, "1", new_action)
      assert player.actions["1"][:vote] == new_action
    end
  end

  describe "kill_player/4" do
    setup [:player_map, :additional_player_map]

    test "sets player to alive false, and calculates correct win (werewolf)", context do
      {:ok, players, win, targets} = Player.kill_player(context[:player_map], 1, "villager")
      assert players["villager"].alive == false
      assert Enum.at(targets, 0).target == "villager"
      assert win == :no_win
      {:ok, players, win, targets} = Player.kill_player(players, 1, "detective")
      assert Enum.at(targets, 0).target == "detective"
      assert players["detective"].alive == false
      assert win == :werewolf_win
    end

    test "not update players when no target", context do
      {:ok, players, _, targets} = Player.kill_player(context[:player_map], 1, :none)
      assert targets == []
      assert players == context[:player_map]
    end

    test "not update players when target equals heal target", context do
      {:ok, players, _, targets} =
        Player.kill_player(context[:player_map], 1, "villager", "villager")

      assert players == context[:player_map]
      assert targets == []
      assert players["villager"].alive == true
    end

    test "sets player to alive false when heal target different", context do
      {:ok, players, _, _} = Player.kill_player(context[:player_map], 1, "villager", "detective")
      assert players["villager"].alive == false
    end

    test "sets hunter to alive false then sets hunter target to alive false", context do
      {:ok, players, _, _} =
        Player.kill_player(context[:additional_player_map], 1, "hunter_action", "little_girl")

      assert players["detective"].alive == false
      assert players["hunter_action"].alive == false
    end

    test "sets hunter to alive false but ignores hunter target if healed", context do
      {:ok, players, _, _} =
        Player.kill_player(context[:additional_player_map], 1, "hunter_action", "detective")

      assert players["detective"].alive == true
      assert players["hunter_action"].alive == false
    end

    test "sets hunter to alive false and no further death if no hunt action", context do
      {:ok, players, _, _} =
        Player.kill_player(context[:additional_player_map], 1, "hunter", "detective")

      assert players["hunter"].alive == false
    end

    test "calculates a villager win when no more werewolves", context do
      {:ok, _, win, _} = Player.kill_player(context[:player_map], 1, "werewolf")
      assert win == :village_win
    end

    test "calculates no win when werewolf and villagers", context do
      {:ok, _, win, _} = Player.kill_player(context[:player_map], 1, :none)
      assert win == :no_win
    end

    test "a fool win if killed on day phase", context do
      {:ok, players, win, targets} =
        Player.kill_player(context[:additional_player_map], 2, "fool")

      assert players["fool"].alive == false
      assert win == :fool_win
    end

    test "not a fool win if killed on night phase", context do
      {:ok, players, win, targets} =
        Player.kill_player(context[:additional_player_map], 1, "fool")

      assert players["fool"].alive == false
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
