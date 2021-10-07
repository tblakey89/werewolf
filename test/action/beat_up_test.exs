defmodule Werewolf.Action.BeatUpTest do
  use ExUnit.Case
  alias Werewolf.{Player, Action}
  import Werewolf.Support.PlayerTestSetup

  describe "resolve/4" do
    setup [:additional_player_map]

    test "when werewolf_thug alive, successfully beats up player", context do
      players = context[:additional_player_map]

      {:ok, player} =
        Player.add_action(players["werewolf_thug"], 1, Action.new(:beat_up, "villager"))

      players = put_in(players["werewolf_thug"], player)

      {:ok, players} = Action.BeatUp.resolve(players, 1, [])
      assert players["villager"].statuses == [:silenced]
      assert players["villager"].actions[1][:beaten_up].target == "villager"
    end

    test "when werewolf_thug alive, but target healed fails to beat up player", context do
      players = context[:additional_player_map]

      {:ok, player} =
        Player.add_action(players["werewolf_thug"], 1, Action.new(:beat_up, "villager"))

      players = put_in(players["werewolf_thug"], player)

      {:ok, players} = Action.BeatUp.resolve(players, 1, ["villager"])
      assert players["villager"].statuses == []
      assert players["villager"].actions == %{}
    end

    test "when werewolf_thug alive, but no beat up action", context do
      players = context[:additional_player_map]
      {:ok, players} = Action.BeatUp.resolve(players, 1, [])
      assert players["villager"].statuses == []
    end
  end
end
