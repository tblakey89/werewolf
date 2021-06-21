defmodule Werewolf.OptionsTest do
  use ExUnit.Case
  import Werewolf.Support.PlayerTestSetup
  alias Werewolf.Options

  describe "check/3" do
    test "end_phase check, automated user, allow_host_end_phase true" do
      options = %Options{allow_host_end_phase: true}
      assert Options.check(options, :end_phase, :automated) == :ok
    end

    test "end_phase check, automated user, allow_host_end_phase false" do
      options = %Options{allow_host_end_phase: false}
      assert Options.check(options, :end_phase, :automated) == :ok
    end

    test "end_phase check, any user, allow_host_end_phase true" do
      options = %Options{allow_host_end_phase: true}
      assert Options.check(options, :end_phase, %{}) == :ok
    end

    test "end_phase check, any user, allow_host_end_phase false" do
      options = %Options{allow_host_end_phase: false}

      assert Options.check(options, :end_phase, %{}) ==
               {:error, :allow_host_end_phase_not_enabled}
    end

    test "claim_role check, any user, allow_claim_role true" do
      options = %Options{allow_claim_role: true}
      assert Options.check(options, :claim_role, %{}) == :ok
    end

    test "claim_role check, any user, allow_claim_role false" do
      options = %Options{allow_claim_role: false}
      assert Options.check(options, :claim_role, %{}) == {:error, :allow_claim_role_not_enabled}
    end
  end
end
