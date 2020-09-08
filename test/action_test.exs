defmodule Werewolf.ActionTest do
  use ExUnit.Case
  alias Werewolf.{Player, Action}
  import Werewolf.Support.PlayerTestSetup

  describe "new/2" do
    test "returns an Action struct when called" do
      assert %Action{type: :vote, target: "user"} = Action.new(:vote, "user")
    end
  end

  describe "resolve_inspect_action/2" do
    setup [:player_map, :additional_player_map]

    test "when detective alive, successfully inspects player", context do
      players = context[:player_map]
      {:ok, player} = Player.add_action(players["detective"], 1, Action.new(:inspect, "villager"))
      players = put_in(players["detective"], player)

      {:ok, players} = Action.resolve_inspect_action(players, 1)
      assert players["detective"].actions[1][:inspect].result == :villager
    end

    test "when detective alive, successfully inspects werewolf player", context do
      players = context[:player_map]
      {:ok, player} = Player.add_action(players["detective"], 1, Action.new(:inspect, "werewolf"))
      players = put_in(players["detective"], player)

      {:ok, players} = Action.resolve_inspect_action(players, 1)
      assert players["detective"].actions[1][:inspect].result == :werewolf
    end

    test "when detective dead, does not resolve action", context do
      players = context[:player_map]
      {:ok, player} = Player.add_action(players["detective"], 1, Action.new(:inspect, "villager"))
      players = put_in(players["detective"], player)
      players = put_in(players["detective"].alive, false)

      {:ok, players} = Action.resolve_inspect_action(players, 1)
      assert players["detective"].actions[1][:inspect].result == nil
    end

    test "when detective alive, but no inspect action", context do
      players = context[:player_map]
      {:ok, players} = Action.resolve_inspect_action(players, 1)
      assert players == context[:player_map]
    end

    test "when little_girl alive, successfully inspects player, gets activity", context do
      players = context[:additional_player_map]
      {:ok, player} = Player.add_action(players["detective"], 1, Action.new(:inspect, "villager"))
      players = put_in(players["detective"], player)
      {:ok, little_girl_player} = Player.add_action(players["little_girl"], 1, Action.new(:inspect, "detective"))
      players = put_in(players["little_girl"], little_girl_player)

      {:ok, players} = Action.resolve_inspect_action(players, 1)
      assert players["little_girl"].actions[1][:inspect].result == true
    end

    test "when little_girl alive, successfully inspects player, gets false for detective with no action", context do
      players = context[:additional_player_map]
      {:ok, player} = Player.add_action(players["little_girl"], 1, Action.new(:inspect, "detective"))
      players = put_in(players["little_girl"], player)

      {:ok, players} = Action.resolve_inspect_action(players, 1)
      assert players["little_girl"].actions[1][:inspect].result == false
    end
  end

  describe "resolve_heal_action/2" do
    setup [:player_map]

    test "when doctor alive, successfully heals player", context do
      players = context[:player_map]
      {:ok, player} = Player.add_action(players["doctor"], 1, Action.new(:heal, "villager"))
      players = put_in(players["doctor"], player)

      {:ok, heal_target} = Action.resolve_heal_action(players, 1)
      assert heal_target == "villager"
    end

    test "when doctor dead, does not resolve action", context do
      players = context[:player_map]
      {:ok, player} = Player.add_action(players["doctor"], 1, Action.new(:heal, "villager"))
      players = put_in(players["doctor"], player)
      players = put_in(players["doctor"].alive, false)

      {:ok, heal_target} = Action.resolve_heal_action(players, 1)
      assert heal_target == :none
    end

    test "when doctor alive, but no heal action", context do
      players = context[:player_map]
      {:ok, heal_target} = Action.resolve_heal_action(players, 1)
      assert heal_target == :none
    end
  end
end
