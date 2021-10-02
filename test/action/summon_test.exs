defmodule Werewolf.Action.SummonTest do
  use ExUnit.Case
  alias Werewolf.{Player, Action}
  import Werewolf.Support.PlayerTestSetup

  describe "resolve/2" do
    setup [:additional_player_map]

    test "when summoner alive, successfully summons player", context do
      players = context[:additional_player_map]
      {:ok, player} = Player.add_action(players["summoner"], 1, Action.new(:summon, "villager"))
      players = put_in(players["villager"].alive, false)
      players = put_in(players["summoner"], player)

      {:ok, players} = Action.Summon.resolve(players, 1)
      assert players["villager"].alive == false
      assert players["villager"].role == :ghost
      assert players["villager"].actions[1][:summoned].target == "villager"
      assert players["summoner"].actions[1][:summon].result == "villager"
    end

    test "when summoner alive, but no summon action", context do
      players = context[:additional_player_map]
      players = put_in(players["villager"].alive, false)
      {:ok, players} = Action.Summon.resolve(players, 1)
      assert players["villager"].role == :villager
      assert players["villager"].actions[1] == nil
    end
  end
end
