defmodule Werewolf.Action.InspectTest do
  use ExUnit.Case
  alias Werewolf.{Player, Action}
  import Werewolf.Support.PlayerTestSetup

  describe "resolve/2" do
    setup [:player_map, :additional_player_map]

    test "when detective alive, successfully inspects player", context do
      players = context[:player_map]
      {:ok, player} = Player.add_action(players["detective"], 1, Action.new(:inspect, "villager"))
      players = put_in(players["detective"], player)

      {:ok, players} = Action.Inspect.resolve(players, 1)
      assert players["detective"].actions[1][:inspect].result == :villager
    end

    test "when detective alive, successfully inspects werewolf player", context do
      players = context[:player_map]
      {:ok, player} = Player.add_action(players["detective"], 1, Action.new(:inspect, "werewolf"))
      players = put_in(players["detective"], player)

      {:ok, players} = Action.Inspect.resolve(players, 1)
      assert players["detective"].actions[1][:inspect].result == :werewolf
    end

    test "when detective alive, unsuccessfully inspects dead werewolf player", context do
      players = context[:player_map]
      {:ok, player} = Player.add_action(players["detective"], 1, Action.new(:inspect, "werewolf"))
      players = put_in(players["werewolf"].alive, false)
      players = put_in(players["detective"], player)

      {:ok, players} = Action.Inspect.resolve(players, 1)
      assert players["detective"].actions[1][:inspect].result == nil
    end

    test "when detective alive, gets wrong result from player with transform action", context do
      players = context[:additional_player_map]

      {:ok, player} =
        Player.add_action(players["detective"], 1, Action.new(:inspect, "werewolf_mage"))

      players = put_in(players["detective"], player)

      {:ok, transform_player} =
        Player.add_action(players["werewolf_mage"], 1, Action.new(:transform, "doctor"))

      players = put_in(players["werewolf_mage"], transform_player)

      {:ok, players} = Action.Inspect.resolve(players, 1)
      assert players["detective"].actions[1][:inspect].result == :doctor
    end

    test "when detective alive, but no inspect action", context do
      players = context[:player_map]
      {:ok, players} = Action.Inspect.resolve(players, 1)
      assert players == context[:player_map]
    end

    test "when little_girl alive, successfully inspects player, gets activity", context do
      players = context[:additional_player_map]
      {:ok, player} = Player.add_action(players["detective"], 1, Action.new(:inspect, "villager"))
      players = put_in(players["detective"], player)

      {:ok, little_girl_player} =
        Player.add_action(players["little_girl"], 1, Action.new(:inspect, "detective"))

      players = put_in(players["little_girl"], little_girl_player)

      {:ok, players} = Action.Inspect.resolve(players, 1)
      assert players["little_girl"].actions[1][:inspect].result == true
    end

    test "when little_girl alive, successfully inspects player, gets false for detective with no action",
         context do
      players = context[:additional_player_map]

      {:ok, player} =
        Player.add_action(players["little_girl"], 1, Action.new(:inspect, "detective"))

      players = put_in(players["little_girl"], player)

      {:ok, players} = Action.Inspect.resolve(players, 1)
      assert players["little_girl"].actions[1][:inspect].result == false
    end

    test "when devil alive, successfully inspects player", context do
      players = context[:additional_player_map]
      {:ok, player} = Player.add_action(players["devil"], 1, Action.new(:inspect, "villager"))
      players = put_in(players["devil"], player)

      {:ok, players} = Action.Inspect.resolve(players, 1)
      assert players["devil"].actions[1][:inspect].result == :villager
    end
  end
end
