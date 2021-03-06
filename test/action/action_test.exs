defmodule Werewolf.ActionTest do
  use ExUnit.Case
  alias Werewolf.{Player, Action, KillTarget}
  import Werewolf.Support.PlayerTestSetup

  describe "new/2" do
    test "returns an Action struct when called" do
      assert %Action{type: :vote, target: "user"} = Action.new(:vote, "user")
    end
  end
end
