defmodule Werewolf.WinCheckTest do
  use ExUnit.Case
  import Werewolf.Support.PlayerTestSetup
  alias Werewolf.WinCheck

  describe "check_for_Wins/2" do
    setup [:player_map]

    test "calculates a villager win when no more werewolves", context do
      players = context[:player_map]
      players = put_in(players["werewolf"].alive, false)
      {:ok, wins} = WinCheck.check_for_wins(nil, players)
      assert wins == [:village_win]
    end

    test "calculates no win when werewolf and villagers", context do
      {:ok, wins} = WinCheck.check_for_wins(nil, context[:player_map])
      assert wins == []
    end

    test "calculates fool win, when fool provided", context do
      players = context[:player_map]
      players = put_in(players["werewolf"].alive, false)
      {:ok, wins} = WinCheck.check_for_wins(:fool_win, players)
      assert wins == [:fool_win]
    end

    test "calculates werewolf win, when werewolves equal villagers", context do
      players = context[:player_map]
      players = put_in(players["villager"].alive, false)
      players = put_in(players["detective"].alive, false)
      {:ok, wins} = WinCheck.check_for_wins(nil, players)
      assert wins == [:werewolf_win]
    end
  end
end
