defmodule Werewolf.Action.WatchTest do
  use ExUnit.Case
  alias Werewolf.{Player, Action, Options}
  import Werewolf.Support.PlayerTestSetup

  describe "resolve/2" do
    setup [:player_map, :additional_player_map]

    test "when little girl alive, successfully watches player", context do
      players = context[:additional_player_map]

      {:ok, player} =
        Player.add_action(players["little_girl"], 1, Action.new(:watch, "detective"))

      {:ok, detective} =
        Player.add_action(players["detective"], 1, Action.new(:inspect, "werewolf"))

      players = put_in(players["little_girl"], player)
      players = put_in(players["detective"], detective)

      {:ok, players} = Action.Watch.resolve(players, 1)
      assert players["little_girl"].actions[1][:watch].result == "werewolf"
    end

    test "when little girl alive, successfully watches but no action", context do
      players = context[:additional_player_map]
      {:ok, player} = Player.add_action(players["little_girl"], 1, Action.new(:watch, "villager"))
      players = put_in(players["little_girl"], player)

      {:ok, players} = Action.Watch.resolve(players, 1)
      assert players["little_girl"].actions[1][:watch].result == 0
    end

    test "when little alive, unsuccessfully watches dead detective player", context do
      players = context[:additional_player_map]

      {:ok, player} =
        Player.add_action(players["little_girl"], 1, Action.new(:watch, "detective"))

      {:ok, detective} =
        Player.add_action(players["detective"], 1, Action.new(:inspect, "werewolf"))

      players = put_in(players["little_girl"], player)
      players = put_in(players["detective"], detective)
      players = put_in(players["detective"].alive, false)

      {:ok, players} = Action.Watch.resolve(players, 1)
      assert players["little_girl"].actions[1][:watch].result == nil
    end

    test "when little_girl alive, gets wrong result from player with transform action", context do
      players = context[:additional_player_map]

      {:ok, player} =
        Player.add_action(players["little_girl"], 1, Action.new(:watch, "werewolf_mage"))

      players = put_in(players["little_girl"], player)

      {:ok, transform_player} =
        Player.add_action(players["werewolf_mage"], 1, Action.new(:transform, "doctor"))

      players = put_in(players["werewolf_mage"], transform_player)

      {:ok, player} = Player.add_action(players["doctor"], 1, Action.new(:heal, "detective"))

      players = put_in(players["doctor"], player)

      {:ok, players} = Action.Watch.resolve(players, 1)
      assert players["little_girl"].actions[1][:watch].result == "detective"
    end

    test "when little girl alive, but no watch action", context do
      players = context[:additional_player_map]
      {:ok, players} = Action.Watch.resolve(players, 1)
      assert players == context[:additional_player_map]
    end
  end
end
