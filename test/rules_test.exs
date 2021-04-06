defmodule Werewolf.RulesTest do
  use ExUnit.Case
  alias Werewolf.Rules

  describe "new/0" do
    test "returns Rules struct" do
      rules = Rules.new()
      assert rules == %Rules{state: :initialized}
    end
  end

  describe "check/2 :edit_game when initialized" do
    setup [:new_game, :initialized_rules]

    test "returns :ok tuple when able to edit_game", context do
      rules = context[:rules]
      assert {:ok, rules} == Rules.check(context[:rules], {:edit_game, context[:game]})
    end
  end

  describe "check/2 :edit_game when ready" do
    setup [:new_game, :ready_rules]

    test "returns :ok tuple when able to edit_game", context do
      rules = context[:ready_rules]
      assert {:ok, rules} == Rules.check(context[:ready_rules], {:edit_game, context[:game]})
    end
  end

  describe "check/2 :edit_game when started" do
    setup [:new_game, :day_rules]

    test "returns :ok tuple when able to edit_game", context do
      rules = context[:day_rules]

      assert {:error, :invalid_action} ==
               Rules.check(context[:day_rules], {:edit_game, context[:game]})
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

  describe "check/2 :add_player when 4 players" do
    setup [:pre_ready_game, :ready_rules, :initialized_rules]

    test "returns ready rules when hitting minimum required", context do
      rules = context[:ready_rules]
      assert {:ok, rules} == Rules.check(context[:rules], {:add_player, context[:game]})
    end
  end

  describe "check/2 :add_player when enough players and :ready" do
    setup [:ready_game, :ready_rules]

    test "returns :ok tuple when able to add players", context do
      rules = context[:ready_rules]
      assert {:ok, rules} == Rules.check(context[:ready_rules], {:add_player, context[:game]})
    end
  end

  describe "check/2 :add_player when too many players and :ready" do
    setup [:full_game, :ready_rules]

    test "returns error as game not ready", context do
      assert {:error, :game_full} ==
               Rules.check(context[:ready_rules], {:add_player, context[:game]})
    end
  end

  describe "check/2 :remove_player when :initialised" do
    setup [:new_game, :initialized_rules]

    test "returns :ok tuple when able to remove player", context do
      rules = context[:rules]
      assert {:ok, rules} == Rules.check(context[:rules], {:remove_player, context[:game]})
    end
  end

  describe "check/2 :remove_player when :ready with 8 players" do
    setup [:ready_game, :ready_rules, :initialized_rules]

    test "returns :ok tuple and initialised rules", context do
      rules = context[:rules]
      assert {:ok, rules} == Rules.check(context[:ready_rules], {:remove_player, context[:game]})
    end
  end

  describe "check/2 :remove_player when :ready with full game" do
    setup [:full_game, :ready_rules]

    test "returns :ok tuple and ready rules", context do
      rules = context[:ready_rules]
      assert {:ok, rules} == Rules.check(context[:ready_rules], {:remove_player, context[:game]})
    end
  end

  describe "check/2 :remove_player from launched game" do
    setup [:day_rules]

    test "returns error, invalid action", context do
      assert {:error, :invalid_action} ==
               Rules.check(context[:day_rules], {:remove_player, context[:game]})
    end
  end

  describe "check/2 :launch when state is :ready" do
    setup [:full_game, :ready_rules]

    test "returns :ok, and begins first :night_phase", context do
      assert {:ok, rules} = Rules.check(context[:ready_rules], :launch)
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
      assert {:ok, rules} = Rules.check(context[:day_rules], {:end_phase, :village_win})
      assert rules.state == :game_over
    end

    test "receives :error when state is not a day_phase/night_phase", context do
      assert {:error, :invalid_action} = Rules.check(context[:rules], {:end_phase, :village_win})
    end
  end

  describe "check/2 when :end_phase when state is :night_phase" do
    setup [:night_rules]

    test "returns :ok, and day phase when not a win", context do
      assert {:ok, rules} = Rules.check(context[:night_rules], {:end_phase, :no_win})
      assert rules.state == :day_phase
    end

    test "returns :ok, and game_over when is a win", context do
      assert {:ok, rules} = Rules.check(context[:night_rules], {:end_phase, :village_win})
      assert rules.state == :game_over
    end
  end

  describe "is_playing?/1" do
    setup [:night_rules, :day_rules, :ready_rules]

    test "returns false when not playing", context do
      assert false == Rules.is_playing?(context[:ready_rules])
    end

    test "returns true when day_phase", context do
      assert true == Rules.is_playing?(context[:day_rules])
    end

    test "returns true when night_phase", context do
      assert true == Rules.is_playing?(context[:night_rules])
    end
  end

  defp initialized_rules(_context), do: [rules: Rules.new()]

  defp ready_rules(_context), do: [ready_rules: %Rules{state: :ready}]

  defp day_rules(_context), do: [day_rules: %Rules{state: :day_phase}]

  defp night_rules(_context), do: [night_rules: %Rules{state: :night_phase}]

  defp new_game(_context), do: [game: %{players: generate_players(1)}]

  defp full_game(_context), do: [game: %{players: generate_players(18)}]

  defp pre_ready_game(_context), do: [game: %{players: generate_players(4)}]

  defp ready_game(_context), do: [game: %{players: generate_players(5)}]

  defp generate_players(amount), do: for(_ <- 1..amount, do: %{})
end
