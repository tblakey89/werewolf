defmodule Werewolf.PlayerRulesTest do
  use ExUnit.Case
  import Werewolf.Support.PlayerTestSetup
  alias Werewolf.PlayerRules

  describe "host_check/2" do
    setup [:host_player_map, :regular_player_map, :user, :alt_user]

    test "when host player, returns ok tuple", context do
      assert :ok = PlayerRules.host_check(context[:host_player_map], context[:user])
    end

    test "when user is not a player, returns error tuple", context do
      assert {:error, :unauthorized} = PlayerRules.host_check(context[:regular_player_map], context[:user])
    end

    test "when user is a player but not host, returns error tuple", context do
      assert {:error, :unauthorized} = PlayerRules.host_check(context[:regular_player_map], context[:alt_user])
    end
  end

  describe "player_check/2" do
    setup [:regular_player_map, :alt_user]

    test "when player in game, returns ok tuple", context do
      assert {:ok, _player} = PlayerRules.player_check(context[:regular_player_map], context[:alt_user])
    end

    test "when user is not a player, returns error tuple", context do
      assert {:error, :not_in_game} = PlayerRules.player_check(%{}, context[:alt_user])
    end
  end

  describe "unique_check/2" do
    setup [:regular_player_map, :alt_user]

    test "when player not in game, returns ok tuple", context do
      players = %{}
      assert {:ok, _players} = PlayerRules.unique_check(players, context[:alt_user])
    end

    test "when user is in game, returns error tuple", context do
      assert {:error, :user_already_joined} = PlayerRules.unique_check(context[:regular_player_map], context[:alt_user])
    end
  end
end
