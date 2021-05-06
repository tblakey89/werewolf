defmodule Werewolf.Action.OverruleTest do
  use ExUnit.Case
  alias Werewolf.{Player, Action}
  import Werewolf.Support.PlayerTestSetup

  describe "resolve/4" do
    setup [:additional_player_map]

    test "when judge alive, successfully overrules player", context do
      players = context[:additional_player_map]
      {:ok, player} = Player.add_action(players["judge"], 1, Action.new(:overrule, "villager"))
      players = put_in(players["judge"], player)

      {:ok, players, overrule_targets} = Action.Overrule.resolve(players, 1)
      assert players["villager"].alive == false
      assert(length(overrule_targets)) == 1
      assert(Enum.at(overrule_targets, 0).type) == :overrule
      assert(Enum.at(overrule_targets, 0).target) == "villager"
    end

    test "when judge alive, but no overrule action", context do
      players = context[:additional_player_map]
      {:ok, players, overrule_targets} = Action.Overrule.resolve(players, 1)
      assert players["villager"].alive == true
      assert(length(overrule_targets)) == 0
    end
  end
end
