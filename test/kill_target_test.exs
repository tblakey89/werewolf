defmodule Werewolf.KillTargetTest do
  use ExUnit.Case
  alias Werewolf.KillTarget

  describe "new/2" do
    test "returns a KillTarget struct when called" do
      assert %KillTarget{type: :werewolf, target: "user"} = KillTarget.new(:werewolf, "user")
    end
  end
end
