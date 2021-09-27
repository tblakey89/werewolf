defmodule Werewolf.Action.ResurrectTest do
  use ExUnit.Case
  alias Werewolf.{Player, Action, KillTarget}
  import Werewolf.Support.PlayerTestSetup

  describe "resolve/2" do
    setup [:additional_player_map]

    test "when witch alive, successfully resurrects player", context do
      players = context[:additional_player_map]
      {:ok, player} = Player.add_action(players["witch"], 1, Action.new(:resurrect, "villager"))
      players = put_in(players["villager"].alive, false)
      players = put_in(players["witch"], player)

      {:ok, players, targets} = Action.Resurrect.resolve(players, 1)
      assert players["villager"].alive == true
      assert(length(targets)) == 1
      assert(Enum.at(targets, 0).type) == :resurrect
      assert(Enum.at(targets, 0).target) == "villager"
    end

    test "when witch alive, successfully resurrects lover, removing lover bool", context do
      players = context[:additional_player_map]
      {:ok, player} = Player.add_action(players["witch"], 1, Action.new(:resurrect, "villager"))
      players = put_in(players["villager"].alive, false)
      players = put_in(players["villager"].lover, true)
      players = put_in(players["villager"].win_condition, :lover_win)
      players = put_in(players["witch"], player)

      {:ok, players, targets} = Action.Resurrect.resolve(players, 1)
      assert players["villager"].alive == true
      assert players["villager"].lover == false
      assert players["villager"].win_condition == :village_win
      assert(length(targets)) == 1
      assert(Enum.at(targets, 0).type) == :resurrect
      assert(Enum.at(targets, 0).target) == "villager"
    end

    test "when witch alive, but no resurrect action", context do
      players = context[:additional_player_map]
      players = put_in(players["villager"].alive, false)
      {:ok, players, targets} = Action.Resurrect.resolve(players, 1)
      assert players["villager"].alive == false
      assert(length(targets)) == 0
    end
  end
end
