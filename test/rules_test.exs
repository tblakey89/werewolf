defmodule Werewolf.RulesTest do
  use ExUnit.Case
  alias Werewolf.Rules

  describe "new/0" do
    test "returns Rules struct" do
      rules = Rules.new()
      assert rules == %Rules{state: :initialized}
    end
  end

  describe "check/2 :add_player not full" do
    setup [:new_game, :initialized_rules]
    test "returns :ok tuple when able to add players", context do
      rules = context[:rules]
      assert {:ok, rules} == Rules.check(context[:rules], {:add_player, context[:game]})
    end
  end

  describe "check/2 :add_player full" do
    setup [:full_game, :initialized_rules]
    test "returns :error tuple when unable to add players", context do
      assert {:error, :game_full} == Rules.check(context[:rules], {:add_player, context[:game]})
    end
  end

  describe "check/2 :set_as_ready when enough players" do
    setup [:full_game, :initialized_rules]
    test "returns ok, with state set as :ready", context do
      assert {:ok, rules} = Rules.check(context[:rules], {:set_as_ready, context[:game]})
      assert rules.state == :ready
    end
  end

  describe "check/2 :set_as_ready when too few players" do
    setup [:new_game, :initialized_rules]
    test "returns error as game not ready", context do
      assert {:error, :game_not_ready} = Rules.check(context[:rules], {:set_as_ready, context[:game]})
    end
  end

  describe "check/2 :launch when state is :ready" do
    setup [:full_game, :ready_rules]
    test "returns :ok, and begins first :night_phase", context do
      assert {:ok, rules} = Rules.check(context[:rules], :launch)
      assert rules.state == :night_phase
    end
  end

  describe "check/2 :launch when state is not :ready" do
    setup [:new_game, :initialized_rules]
    test "returns :invalid_action", context do
      assert {:error, :invalid_action} = Rules.check(context[:rules], :launch)
    end
  end

  describe "check/2 when :end_phase when state is :day_phase" do
    setup [:day_rules, :ready_rules]
    test "returns :ok, and night phase when not a win", context do
      assert {:ok, rules} = Rules.check(context[:day_rules], {:end_phase, :no_win})
      assert rules.state == :night_phase
    end

    test "returns :ok, and game_over when is a win", context do
      assert {:ok, rules} = Rules.check(context[:day_rules], {:end_phase, :villager_win})
      assert rules.state == :game_over
    end

    test "receives :error when state is not a day_phase/night_phase", context do
      assert {:error, :invalid_action} = Rules.check(context[:rules], {:end_phase, :villager_win})
    end
  end

  describe "check/2 when :end_phase when state is :night_phase" do
    setup [:night_rules]
    test "returns :ok, and day phase when not a win", context do
      assert {:ok, rules} = Rules.check(context[:night_rules], {:end_phase, :no_win})
      assert rules.state == :day_phase
    end

    test "returns :ok, and game_over when is a win", context do
      assert {:ok, rules} = Rules.check(context[:night_rules], {:end_phase, :villager_win})
      assert rules.state == :game_over
    end
  end

  defp initialized_rules(_context), do: [rules: Rules.new()]

  defp ready_rules(_context), do: [rules: %Rules{state: :ready}]

  defp day_rules(_context), do: [day_rules: %Rules{state: :day_phase}]

  defp night_rules(_context), do: [night_rules: %Rules{state: :night_phase}]

  defp new_game(_context), do: [game: %{players: generate_players(1)}]

  defp full_game(_context), do: [game: %{players: generate_players(18)}]

  defp generate_players(amount), do: for _ <- 1..amount, do: %{}
end
