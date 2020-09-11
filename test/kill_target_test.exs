defmodule Werewolf.KillTargetTest do
  use ExUnit.Case
  alias Werewolf.KillTarget

  describe "new/2" do
    test "returns a KillTarget struct when called" do
      assert %KillTarget{type: :werewolf, target: "user"} = KillTarget.new(:werewolf, "user")
    end
  end

  describe "to_map/1" do
    test "returns a map of type keys to target values" do
      kill_target = KillTarget.new(:werewolf, "user")
      kill_target_two = KillTarget.new(:hunter, "user_two")
      map = KillTarget.to_map([kill_target, kill_target_two])
      assert map[kill_target.type] == kill_target.target
      assert map[kill_target_two.type] == kill_target_two.target
    end
  end
end
