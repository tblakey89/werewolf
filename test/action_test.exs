defmodule Werewolf.ActionTest do
  use ExUnit.Case
  alias Werewolf.{Player, Action, KillTarget}
  import Werewolf.Support.PlayerTestSetup

  describe "new/2" do
    test "returns an Action struct when called" do
      assert %Action{type: :vote, target: "user"} = Action.new(:vote, "user")
    end
  end

  describe "resolve_inspect_action/2" do
    setup [:player_map, :additional_player_map]

    test "when detective alive, successfully inspects player", context do
      players = context[:player_map]
      {:ok, player} = Player.add_action(players["detective"], 1, Action.new(:inspect, "villager"))
      players = put_in(players["detective"], player)

      {:ok, players} = Action.resolve_inspect_action(players, 1)
      assert players["detective"].actions[1][:inspect].result == :villager
    end

    test "when detective alive, successfully inspects werewolf player", context do
      players = context[:player_map]
      {:ok, player} = Player.add_action(players["detective"], 1, Action.new(:inspect, "werewolf"))
      players = put_in(players["detective"], player)

      {:ok, players} = Action.resolve_inspect_action(players, 1)
      assert players["detective"].actions[1][:inspect].result == :werewolf
    end

    test "when detective alive, but no inspect action", context do
      players = context[:player_map]
      {:ok, players} = Action.resolve_inspect_action(players, 1)
      assert players == context[:player_map]
    end

    test "when little_girl alive, successfully inspects player, gets activity", context do
      players = context[:additional_player_map]
      {:ok, player} = Player.add_action(players["detective"], 1, Action.new(:inspect, "villager"))
      players = put_in(players["detective"], player)

      {:ok, little_girl_player} =
        Player.add_action(players["little_girl"], 1, Action.new(:inspect, "detective"))

      players = put_in(players["little_girl"], little_girl_player)

      {:ok, players} = Action.resolve_inspect_action(players, 1)
      assert players["little_girl"].actions[1][:inspect].result == true
    end

    test "when little_girl alive, successfully inspects player, gets false for detective with no action",
         context do
      players = context[:additional_player_map]

      {:ok, player} =
        Player.add_action(players["little_girl"], 1, Action.new(:inspect, "detective"))

      players = put_in(players["little_girl"], player)

      {:ok, players} = Action.resolve_inspect_action(players, 1)
      assert players["little_girl"].actions[1][:inspect].result == false
    end

    test "when devil alive, successfully inspects player", context do
      players = context[:additional_player_map]
      {:ok, player} = Player.add_action(players["devil"], 1, Action.new(:inspect, "villager"))
      players = put_in(players["devil"], player)

      {:ok, players} = Action.resolve_inspect_action(players, 1)
      assert players["devil"].actions[1][:inspect].result == :villager
    end
  end

  describe "resolve_heal_action/2" do
    setup [:player_map]

    test "when doctor alive, successfully heals player", context do
      players = context[:player_map]
      {:ok, player} = Player.add_action(players["doctor"], 1, Action.new(:heal, "villager"))
      players = put_in(players["doctor"], player)

      {:ok, heal_targets} = Action.resolve_heal_action(players, 1)
      assert heal_targets == ["villager"]
    end

    test "when doctor alive, but no heal action", context do
      players = context[:player_map]
      {:ok, heal_targets} = Action.resolve_heal_action(players, 1)
      assert heal_targets == []
    end
  end

  describe "resolve_resurrect_action/2" do
    setup [:additional_player_map]

    test "when witch alive, successfully resurrects player", context do
      players = context[:additional_player_map]
      {:ok, player} = Player.add_action(players["witch"], 1, Action.new(:resurrect, "villager"))
      players = put_in(players["villager"].alive, false)
      players = put_in(players["witch"], player)

      {:ok, players, targets} = Action.resolve_resurrect_action(players, 1)
      assert players["villager"].alive == true
      assert(length(targets)) == 1
      assert(Enum.at(targets, 0).type) == :resurrect
      assert(Enum.at(targets, 0).target) == "villager"
    end

    test "when witch alive, but no resurrect action", context do
      players = context[:additional_player_map]
      players = put_in(players["villager"].alive, false)
      {:ok, players, targets} = Action.resolve_resurrect_action(players, 1)
      assert players["villager"].alive == false
      assert(length(targets)) == 0
    end
  end

  describe "resolve_poison_action/4" do
    setup [:additional_player_map]

    test "when witch alive, successfully poisons player", context do
      players = context[:additional_player_map]
      {:ok, player} = Player.add_action(players["witch"], 1, Action.new(:poison, "villager"))
      players = put_in(players["witch"], player)

      {:ok, players, targets} = Action.resolve_poison_action(players, 1, [], [])
      assert players["villager"].alive == false
      assert(length(targets)) == 1
      assert(Enum.at(targets, 0).type) == :poison
      assert(Enum.at(targets, 0).target) == "villager"
    end

    test "when witch alive, poisons player, but protected", context do
      players = context[:additional_player_map]
      {:ok, player} = Player.add_action(players["witch"], 1, Action.new(:poison, "villager"))
      players = put_in(players["witch"], player)

      {:ok, players, targets} = Action.resolve_poison_action(players, 1, [], ["villager"])
      assert players["villager"].alive == true
      assert(length(targets)) == 0
    end

    test "when witch alive, but no poison action", context do
      players = context[:additional_player_map]
      {:ok, players, targets} = Action.resolve_poison_action(players, 1, [], [])
      assert players["villager"].alive == true
      assert(length(targets)) == 0
    end
  end

  describe "resolve_hunt_action/4" do
    setup [:additional_player_map]

    test "when hunter targetted, successfully hunts player", context do
      players = context[:additional_player_map]
      {:ok, player} = Player.add_action(players["hunter"], 1, Action.new(:hunt, "villager"))
      players = put_in(players["hunter"], player)

      {:ok, players, targets} =
        Action.resolve_hunt_action(players, 1, [KillTarget.new(:vote, "hunter")], [])

      assert players["villager"].alive == false
      assert(length(targets)) == 1
      assert(Enum.at(targets, 0).type) == :hunt
      assert(Enum.at(targets, 0).target) == "villager"
    end

    test "when hunter alive, hunts player, but protected", context do
      players = context[:additional_player_map]
      {:ok, player} = Player.add_action(players["hunter"], 1, Action.new(:hunt, "villager"))
      players = put_in(players["hunter"], player)

      {:ok, players, targets} =
        Action.resolve_hunt_action(players, 1, [KillTarget.new(:vote, "hunter")], ["villager"])

      assert players["villager"].alive == true
      assert(length(targets)) == 0
    end

    test "when hunter not targetted, does not resolve action", context do
      players = context[:additional_player_map]
      {:ok, player} = Player.add_action(players["hunter"], 1, Action.new(:hunt, "villager"))
      players = put_in(players["hunter"], player)

      {:ok, players, targets} = Action.resolve_hunt_action(players, 1, [], [])
      assert players["villager"].alive == true
      assert(length(targets)) == 0
    end

    test "when hunter alive, but no hunt action", context do
      players = context[:additional_player_map]

      {:ok, players, targets} =
        Action.resolve_hunt_action(players, 1, [KillTarget.new(:vote, "hunter")], [])

      assert players["villager"].alive == true
      assert(length(targets)) == 0
    end
  end

  describe "resolve_assassinate_action/4" do
    setup [:additional_player_map]

    test "when ninja alive, successfully assassinates player", context do
      players = context[:additional_player_map]
      {:ok, player} = Player.add_action(players["ninja"], 1, Action.new(:assassinate, "werewolf"))
      players = put_in(players["ninja"], player)

      {:ok, players, targets} = Action.resolve_assassinate_action(players, 1, [], [])
      assert players["werewolf"].alive == false
      assert(length(targets)) == 1
      assert(Enum.at(targets, 0).type) == :assassinate
      assert(Enum.at(targets, 0).target) == "werewolf"
    end

    test "when ninja alive, assassinates player, but protected", context do
      players = context[:additional_player_map]
      {:ok, player} = Player.add_action(players["ninja"], 1, Action.new(:assassinate, "villager"))
      players = put_in(players["ninja"], player)

      {:ok, players, targets} = Action.resolve_assassinate_action(players, 1, [], ["villager"])
      assert players["villager"].alive == true
      assert(length(targets)) == 0
    end

    test "when ninja alive, successfully assassinates player, but commits seppuku", context do
      players = context[:additional_player_map]
      {:ok, player} = Player.add_action(players["ninja"], 1, Action.new(:assassinate, "villager"))
      players = put_in(players["ninja"], player)

      {:ok, players, targets} = Action.resolve_assassinate_action(players, 1, [KillTarget.new(:poison, "werewolf")], [])
      assert players["villager"].alive == false
      assert players["ninja"].alive == false
      assert length(targets) == 3
      assert Enum.at(targets, 0).type == :poison
      assert Enum.at(targets, 0).target == "werewolf"
      assert Enum.at(targets, 1).type == :assassinate
      assert Enum.at(targets, 1).target == "villager"
      assert Enum.at(targets, 2).type == :seppuku
      assert Enum.at(targets, 2).target == "ninja"

    end

    test "when ninja alive, but no assassinate action", context do
      players = context[:additional_player_map]
      {:ok, players, targets} = Action.resolve_assassinate_action(players, 1, [], [])
      assert players["villager"].alive == true
      assert(length(targets)) == 0
    end
  end
end
