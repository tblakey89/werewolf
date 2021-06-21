defmodule Werewolf.PlayerTest do
  use ExUnit.Case
  import Werewolf.Support.PlayerTestSetup
  alias Werewolf.Options

  describe "check/3" do
    test "end_phase check, automated user, allow_host_end_phase true" do
      options = %Options{allow_host_end_phase: true}
      assert Options.check(options, :end_phase, :automated) == true
    end

    test "end_phase check, automated user, allow_host_end_phase false" do
      options = %Options{allow_host_end_phase: false}
      assert Options.check(options, :end_phase, :automated) == true
    end

    test "end_phase check, any user, allow_host_end_phase true" do
      options = %Options{allow_host_end_phase: true}
      assert Options.check(options, :end_phase, %{}) == true
    end

    test "end_phase check, any user, allow_host_end_phase false" do
      options = %Options{allow_host_end_phase: false}
      assert Options.check(options, :end_phase, %{}) == false
    end
  end
end
