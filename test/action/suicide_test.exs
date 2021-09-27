defmodule Werewolf.Action.SuicideTest do
  use ExUnit.Case
  alias Werewolf.{Player, KillTarget, Action}
  import Werewolf.Support.PlayerTestSetup

  describe "resolve/2" do
    setup [:player_map]

    test "when lovers alive, both live", context do
      players = context[:player_map]
      players = put_in(players["werewolf"].lover, true)
      players = put_in(players["villager"].lover, true)

      {:ok, players, targets} = Action.Suicide.resolve(players, [])
      assert players["villager"].alive == true
      assert players["werewolf"].alive == true
      assert(length(targets)) == 0
    end

    test "when one dead, other suicides", context do
      players = context[:player_map]
      players = put_in(players["werewolf"].lover, true)
      players = put_in(players["werewolf"].alive, false)
      players = put_in(players["villager"].lover, true)

      {:ok, players, targets} = Action.Suicide.resolve(players, [])
      assert players["villager"].alive == false
      assert players["werewolf"].alive == false
      assert(length(targets)) == 1
      assert(Enum.at(targets, 0).type) == :suicide
      assert(Enum.at(targets, 0).target) == "villager"
    end

    test "when lovers dead, no action", context do
      players = context[:player_map]
      players = put_in(players["werewolf"].lover, true)
      players = put_in(players["villager"].lover, true)
      players = put_in(players["werewolf"].alive, false)
      players = put_in(players["villager"].alive, false)

      {:ok, players, targets} = Action.Suicide.resolve(players, [])
      assert players["villager"].alive == false
      assert players["werewolf"].alive == false
      assert(length(targets)) == 0
    end
  end
end
