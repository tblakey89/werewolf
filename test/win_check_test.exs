defmodule Werewolf.WinCheckTest do
  use ExUnit.Case
  import Werewolf.Support.PlayerTestSetup
  alias Werewolf.WinCheck

  describe "by_remaining_players/2" do
    setup [:player_map]

    test "calculates a villager win when no more werewolves", context do
      players = context[:player_map]
      players = put_in(players["werewolf"].alive, false)
      {:ok, win} = WinCheck.by_remaining_players(nil, players)
      assert win == :village_win
    end

    test "calculates no win when werewolf and villagers", context do
      {:ok, win} = WinCheck.by_remaining_players(nil, context[:player_map])
      assert win == :no_win
    end

    test "calculates fool win, when fool provided", context do
      players = context[:player_map]
      players = put_in(players["werewolf"].alive, false)
      {:ok, win} = WinCheck.by_remaining_players(:fool_win, players)
      assert win == :fool_win
    end

    test "calculates werewolf win, when werewolves equal villagers", context do
      players = context[:player_map]
      players = put_in(players["villager"].alive, false)
      players = put_in(players["detective"].alive, false)
      {:ok, win} = WinCheck.by_remaining_players(nil, players)
      assert win == :werewolf_win
    end
  end
end
