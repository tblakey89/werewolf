defmodule Werewolf.ActionRulesTest do
  use ExUnit.Case
  import Werewolf.Support.ActionsTestSetup
  alias Werewolf.ActionRules

  describe "valid/3 voting in day phase" do
    setup [
      :vote_action,
      :invalid_vote,
      :player,
      :dead_player,
      :day_state,
      :night_state,
      :players,
      :dead_players
    ]

    test "when able to vote, returns ok tuple", context do
      action = context[:vote_action]

      assert {:ok, action} ==
               ActionRules.valid(context[:day_state], context[:player], action, context[:players])
    end

    test "unable to vote for dead player", context do
      action = context[:invalid_vote]

      assert {:error, :invalid_target} ==
               ActionRules.valid(
                 context[:day_state],
                 context[:player],
                 action,
                 context[:dead_players]
               )
    end

    test "unable to vote when player is dead", context do
      action = context[:vote_action]

      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:day_state],
                 context[:dead_player],
                 action,
                 context[:players]
               )
    end

    test "unable to vote at night", context do
      action = context[:vote_action]

      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:player],
                 action,
                 context[:players]
               )
    end
  end

  describe "valid/3 werewolf" do
    setup [
      :vote_action,
      :invalid_vote,
      :player,
      :werewolf,
      :dead_werewolf,
      :day_state,
      :night_state,
      :players,
      :dead_players
    ]

    test "when able to vote, returns ok tuple", context do
      action = context[:vote_action]

      assert {:ok, action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:werewolf],
                 action,
                 context[:players]
               )
    end

    test "unable to vote for dead player", context do
      action = context[:invalid_vote]

      assert {:error, :invalid_target} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:werewolf],
                 action,
                 context[:dead_players]
               )
    end

    test "unable to vote when werewolf is dead", context do
      action = context[:vote_action]

      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:dead_werewolf],
                 action,
                 context[:players]
               )
    end
  end

  describe "valid/3 doctor" do
    setup [
      :heal_action,
      :player,
      :doctor,
      :dead_doctor,
      :werewolf,
      :day_state,
      :night_state,
      :players,
      :dead_players
    ]

    test "when able to heal, returns ok tuple", context do
      action = context[:heal_action]

      assert {:ok, action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:doctor],
                 action,
                 context[:players]
               )
    end

    test "unable to heal for dead player", context do
      assert {:error, :invalid_target} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:doctor],
                 context[:heal_action],
                 context[:dead_players]
               )
    end

    test "unable to heal when doctor is dead", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:dead_doctor],
                 context[:heal_action],
                 context[:players]
               )
    end

    test "unable to heal in day phase", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:day_state],
                 context[:doctor],
                 context[:heal_action],
                 context[:players]
               )
    end

    test "unable to heal when wrong role", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:werewolf],
                 context[:heal_action],
                 context[:players]
               )
    end
  end

  describe "valid/3 detective" do
    setup [
      :inspect_action,
      :player,
      :detective,
      :dead_detective,
      :werewolf,
      :day_state,
      :night_state,
      :players,
      :dead_players
    ]

    test "when able to inspect, returns ok tuple", context do
      action = context[:inspect_action]

      assert {:ok, action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:detective],
                 action,
                 context[:players]
               )
    end

    test "unable to inspect for dead player", context do
      assert {:error, :invalid_target} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:detective],
                 context[:inspect_action],
                 context[:dead_players]
               )
    end

    test "unable to inspect when detective is dead", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:dead_detective],
                 context[:inspect_action],
                 context[:players]
               )
    end

    test "unable to inspect in day phase", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:day_state],
                 context[:detective],
                 context[:inspect_action],
                 context[:players]
               )
    end

    test "unable to inspect when wrong role", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:werewolf],
                 context[:inspect_action],
                 context[:players]
               )
    end
  end

  describe "valid/3 little_girl" do
    setup [
      :inspect_action,
      :player,
      :little_girl,
      :dead_little_girl,
      :day_state,
      :night_state,
      :players,
      :dead_players
    ]

    test "when able to inspect, returns ok tuple", context do
      action = context[:inspect_action]

      assert {:ok, action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:little_girl],
                 action,
                 context[:players]
               )
    end

    test "unable to inspect for dead player", context do
      assert {:error, :invalid_target} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:little_girl],
                 context[:inspect_action],
                 context[:dead_players]
               )
    end

    test "unable to inspect when little_girl is dead", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:dead_little_girl],
                 context[:inspect_action],
                 context[:players]
               )
    end

    test "unable to inspect in day phase", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:day_state],
                 context[:little_girl],
                 context[:inspect_action],
                 context[:players]
               )
    end
  end

  describe "valid/3 devil" do
    setup [
      :inspect_action,
      :player,
      :devil,
      :dead_devil,
      :day_state,
      :night_state,
      :players,
      :dead_players
    ]

    test "when able to inspect, returns ok tuple", context do
      action = context[:inspect_action]

      assert {:ok, action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:devil],
                 action,
                 context[:players]
               )
    end

    test "unable to inspect for dead player", context do
      assert {:error, :invalid_target} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:devil],
                 context[:inspect_action],
                 context[:dead_players]
               )
    end

    test "unable to inspect when devil is dead", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:dead_devil],
                 context[:inspect_action],
                 context[:players]
               )
    end

    test "unable to inspect in day phase", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:day_state],
                 context[:devil],
                 context[:inspect_action],
                 context[:players]
               )
    end
  end

  describe "valid/3 hunter" do
    setup [
      :hunt_action,
      :player,
      :hunter,
      :dead_hunter,
      :werewolf,
      :day_state,
      :night_state,
      :players,
      :dead_players
    ]

    test "when able to hunt, returns ok tuple", context do
      action = context[:hunt_action]

      assert {:ok, action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:hunter],
                 action,
                 context[:players]
               )
    end

    test "unable to hunt for dead player", context do
      assert {:error, :invalid_target} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:hunter],
                 context[:hunt_action],
                 context[:dead_players]
               )
    end

    test "unable to hunt when hunter is dead", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:dead_hunter],
                 context[:hunt_action],
                 context[:players]
               )
    end

    test "unable to hunt in day phase", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:day_state],
                 context[:hunter],
                 context[:hunt_action],
                 context[:players]
               )
    end

    test "unable to hunt when wrong role", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:werewolf],
                 context[:hunt_action],
                 context[:players]
               )
    end
  end
end
