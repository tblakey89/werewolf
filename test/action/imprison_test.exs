defmodule Werewolf.Action.ImprisonTest do
  use ExUnit.Case
  alias Werewolf.{Player, Action}
  import Werewolf.Support.PlayerTestSetup

  describe "resolve/4" do
    setup [:additional_player_map]

    test "when guard alive, successfully imprisons player", context do
      players = context[:additional_player_map]
      {:ok, player} = Player.add_action(players["guard"], 1, Action.new(:imprison, "villager"))
      players = put_in(players["guard"], player)

      {:ok, players} = Action.Imprison.resolve(players, 1)
      assert players["villager"].statuses == [:imprisoned]
      assert players["villager"].actions[1][:imprisoned].target == "villager"
    end

    test "when guard alive, but no imprison action", context do
      players = context[:additional_player_map]
      {:ok, players} = Action.Imprison.resolve(players, 1)
      assert players["villager"].statuses == []
    end
  end
end
