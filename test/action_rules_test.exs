defmodule Werewolf.ActionRulesTest do
  use ExUnit.Case
  import Werewolf.Support.ActionsTestSetup
  alias Werewolf.ActionRules
  alias Werewolf.Options

  describe "valid/3 voting in day phase" do
    setup [
      :vote_action,
      :no_kill_vote_action,
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
               ActionRules.valid(
                 context[:day_state],
                 context[:player],
                 action,
                 context[:players],
                 %Options{}
               )
    end

    test "able to vote for no_kill when option enabled", context do
      action = context[:no_kill_vote_action]

      assert {:ok, action} ==
               ActionRules.valid(
                 context[:day_state],
                 context[:player],
                 action,
                 context[:players],
                 %Options{allow_no_kill_vote: true}
               )
    end

    test "unable to vote for no_kill when option not enabled", context do
      action = context[:no_kill_vote_action]

      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:day_state],
                 context[:player],
                 action,
                 context[:players],
                 %Options{}
               )
    end

    test "unable to vote for dead player", context do
      action = context[:invalid_vote]

      assert {:error, :invalid_target} ==
               ActionRules.valid(
                 context[:day_state],
                 context[:player],
                 action,
                 context[:dead_players],
                 %Options{}
               )
    end

    test "unable to vote when player is dead", context do
      action = context[:vote_action]

      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:day_state],
                 context[:dead_player],
                 action,
                 context[:players],
                 %Options{}
               )
    end

    test "unable to vote at night", context do
      action = context[:vote_action]

      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:player],
                 action,
                 context[:players],
                 %Options{}
               )
    end
  end

  describe "valid/3 werewolf" do
    setup [
      :vote_action,
      :no_kill_vote_action,
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
                 context[:players],
                 %Options{}
               )
    end

    test "able to vote for no_kill when option enabled", context do
      action = context[:no_kill_vote_action]

      assert {:ok, action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:werewolf],
                 action,
                 context[:players],
                 %Options{allow_no_kill_vote: true}
               )
    end

    test "unable to vote for no_kill when option not enabled", context do
      action = context[:no_kill_vote_action]

      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:werewolf],
                 action,
                 context[:players],
                 %Options{}
               )
    end

    test "unable to vote for dead player", context do
      action = context[:invalid_vote]

      assert {:error, :invalid_target} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:werewolf],
                 action,
                 context[:dead_players],
                 %Options{}
               )
    end

    test "unable to vote when werewolf is dead", context do
      action = context[:vote_action]

      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:dead_werewolf],
                 action,
                 context[:players],
                 %Options{}
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
                 context[:players],
                 %Options{}
               )
    end

    test "unable to heal for dead player", context do
      assert {:error, :invalid_target} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:doctor],
                 context[:heal_action],
                 context[:dead_players],
                 %Options{}
               )
    end

    test "unable to heal when doctor is dead", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:dead_doctor],
                 context[:heal_action],
                 context[:players],
                 %Options{}
               )
    end

    test "unable to heal in day phase", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:day_state],
                 context[:doctor],
                 context[:heal_action],
                 context[:players],
                 %Options{}
               )
    end

    test "unable to heal when have wrong items", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:werewolf],
                 context[:heal_action],
                 context[:players],
                 %Options{}
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
                 context[:players],
                 %Options{}
               )
    end

    test "unable to inspect for dead player", context do
      assert {:error, :invalid_target} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:detective],
                 context[:inspect_action],
                 context[:dead_players],
                 %Options{}
               )
    end

    test "unable to inspect when detective is dead", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:dead_detective],
                 context[:inspect_action],
                 context[:players],
                 %Options{}
               )
    end

    test "unable to inspect in day phase", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:day_state],
                 context[:detective],
                 context[:inspect_action],
                 context[:players],
                 %Options{}
               )
    end

    test "unable to inspect when have wrong items", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:werewolf],
                 context[:inspect_action],
                 context[:players],
                 %Options{}
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
                 context[:players],
                 %Options{}
               )
    end

    test "unable to inspect for dead player", context do
      assert {:error, :invalid_target} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:little_girl],
                 context[:inspect_action],
                 context[:dead_players],
                 %Options{}
               )
    end

    test "unable to inspect when little_girl is dead", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:dead_little_girl],
                 context[:inspect_action],
                 context[:players],
                 %Options{}
               )
    end

    test "unable to inspect in day phase", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:day_state],
                 context[:little_girl],
                 context[:inspect_action],
                 context[:players],
                 %Options{}
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
                 context[:players],
                 %Options{}
               )
    end

    test "unable to inspect for dead player", context do
      assert {:error, :invalid_target} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:devil],
                 context[:inspect_action],
                 context[:dead_players],
                 %Options{}
               )
    end

    test "unable to inspect when devil is dead", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:dead_devil],
                 context[:inspect_action],
                 context[:players],
                 %Options{}
               )
    end

    test "unable to inspect in day phase", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:day_state],
                 context[:devil],
                 context[:inspect_action],
                 context[:players],
                 %Options{}
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
                 context[:players],
                 %Options{}
               )
    end

    test "unable to hunt for dead player", context do
      assert {:error, :invalid_target} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:hunter],
                 context[:hunt_action],
                 context[:dead_players],
                 %Options{}
               )
    end

    test "unable to hunt when hunter is dead", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:dead_hunter],
                 context[:hunt_action],
                 context[:players],
                 %Options{}
               )
    end

    test "unable to hunt in day phase", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:day_state],
                 context[:hunter],
                 context[:hunt_action],
                 context[:players],
                 %Options{}
               )
    end

    test "unable to hunt when have wrong items", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:werewolf],
                 context[:hunt_action],
                 context[:players],
                 %Options{}
               )
    end
  end

  describe "valid/3 witch" do
    setup [
      :resurrect_action,
      :poison_action,
      :player,
      :witch,
      :dead_witch,
      :werewolf,
      :day_state,
      :night_state,
      :players,
      :dead_players
    ]

    test "when able to resurrect, returns ok tuple", context do
      action = context[:resurrect_action]

      assert {:ok, action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:witch],
                 action,
                 context[:dead_players],
                 %Options{}
               )
    end

    test "unable to resurrect for alive player", context do
      assert {:error, :invalid_target} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:witch],
                 context[:resurrect_action],
                 context[:players],
                 %Options{}
               )
    end

    test "unable to resurrect when witch is dead", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:dead_witch],
                 context[:resurrect_action],
                 context[:players],
                 %Options{}
               )
    end

    test "unable to resurrect in day phase", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:day_state],
                 context[:witch],
                 context[:resurrect_action],
                 context[:players],
                 %Options{}
               )
    end

    test "unable to resurrect when have wrong items", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:werewolf],
                 context[:resurrect_action],
                 context[:players],
                 %Options{}
               )
    end

    test "when able to poison, returns ok tuple", context do
      action = context[:poison_action]

      assert {:ok, action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:witch],
                 action,
                 context[:players],
                 %Options{}
               )
    end

    test "unable to poison for dead player", context do
      assert {:error, :invalid_target} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:witch],
                 context[:poison_action],
                 context[:dead_players],
                 %Options{}
               )
    end

    test "unable to poison when witch is dead", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:dead_witch],
                 context[:poison_action],
                 context[:players],
                 %Options{}
               )
    end

    test "unable to poison in day phase", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:day_state],
                 context[:witch],
                 context[:poison_action],
                 context[:players],
                 %Options{}
               )
    end

    test "unable to poison when have wrong items", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:werewolf],
                 context[:poison_action],
                 context[:players],
                 %Options{}
               )
    end
  end

  describe "valid/3 ninja" do
    setup [
      :assassinate_action,
      :player,
      :ninja,
      :dead_hunter,
      :werewolf,
      :day_state,
      :night_state,
      :players,
      :dead_players
    ]

    test "when able to assassinate, returns ok tuple", context do
      action = context[:assassinate_action]

      assert {:ok, action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:ninja],
                 action,
                 context[:players],
                 %Options{}
               )
    end

    test "unable to assassinate for dead player", context do
      assert {:error, :invalid_target} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:ninja],
                 context[:assassinate_action],
                 context[:dead_players],
                 %Options{}
               )
    end

    test "unable to assassinate when ninja is dead", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:dead_ninja],
                 context[:assassinate_action],
                 context[:players],
                 %Options{}
               )
    end

    test "unable to assassinate in day phase", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:day_state],
                 context[:ninja],
                 context[:assassinate_action],
                 context[:players],
                 %Options{}
               )
    end

    test "unable to assassinate when have wrong items", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:werewolf],
                 context[:assassinate_action],
                 context[:players],
                 %Options{}
               )
    end
  end

  describe "valid/3 werewolf_thief" do
    setup [
      :steal_action,
      :vote_action,
      :player,
      :werewolf_thief,
      :dead_werewolf_thief,
      :werewolf,
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
                 context[:werewolf_thief],
                 action,
                 context[:players],
                 %Options{}
               )
    end

    test "when able to steal, returns ok tuple", context do
      action = context[:steal_action]

      assert {:ok, action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:werewolf_thief],
                 action,
                 context[:players],
                 %Options{}
               )
    end

    test "unable to steal from dead player", context do
      assert {:error, :invalid_target} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:werewolf_thief],
                 context[:steal_action],
                 context[:dead_players],
                 %Options{}
               )
    end

    test "unable to steal when werewolf_thief is dead", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:dead_werewolf_thief],
                 context[:steal_action],
                 context[:players],
                 %Options{}
               )
    end

    test "unable to steal in day phase", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:day_state],
                 context[:werewolf_thief],
                 context[:steal_action],
                 context[:players],
                 %Options{}
               )
    end

    test "unable to steal when have wrong items", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:werewolf],
                 context[:steal_action],
                 context[:players],
                 %Options{}
               )
    end
  end

  describe "valid/3 werewolf_detective" do
    setup [
      :inspect_action,
      :player,
      :werewolf_detective,
      :dead_werewolf_detective,
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
                 context[:werewolf_detective],
                 action,
                 context[:players],
                 %Options{}
               )
    end

    test "unable to inspect for dead player", context do
      assert {:error, :invalid_target} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:werewolf_detective],
                 context[:inspect_action],
                 context[:dead_players],
                 %Options{}
               )
    end

    test "unable to inspect when werewolf_detective is dead", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:dead_werewolf_detective],
                 context[:inspect_action],
                 context[:players],
                 %Options{}
               )
    end

    test "unable to inspect in day phase", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:day_state],
                 context[:werewolf_detective],
                 context[:inspect_action],
                 context[:players],
                 %Options{}
               )
    end
  end

  describe "valid/3 werewolf_saboteur" do
    setup [
      :sabotage_action,
      :player,
      :werewolf_saboteur,
      :dead_hunter,
      :werewolf,
      :day_state,
      :night_state,
      :players,
      :dead_players
    ]

    test "when able to sabotage, returns ok tuple", context do
      action = context[:sabotage_action]

      assert {:ok, action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:werewolf_saboteur],
                 action,
                 context[:players],
                 %Options{}
               )
    end

    test "unable to sabotage from dead player", context do
      assert {:error, :invalid_target} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:werewolf_saboteur],
                 context[:sabotage_action],
                 context[:dead_players],
                 %Options{}
               )
    end

    test "unable to sabotage when werewolf_saboteur is dead", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:dead_werewolf_saboteur],
                 context[:sabotage_action],
                 context[:players],
                 %Options{}
               )
    end

    test "unable to sabotage in day phase", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:day_state],
                 context[:werewolf_saboteur],
                 context[:sabotage_action],
                 context[:players],
                 %Options{}
               )
    end

    test "unable to sabotage when have wrong items", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:werewolf],
                 context[:sabotage_action],
                 context[:players],
                 %Options{}
               )
    end
  end

  describe "valid/3 werewolf_collector" do
    setup [
      :curse_action,
      :player,
      :werewolf_collector,
      :dead_werewolf_collector,
      :werewolf,
      :day_state,
      :night_state,
      :players,
      :dead_players
    ]

    test "when able to curse, returns ok tuple", context do
      action = context[:curse_action]

      assert {:ok, action} ==
               ActionRules.valid(
                 context[:day_state],
                 context[:werewolf_collector],
                 action,
                 context[:players],
                 %Options{}
               )
    end

    test "unable to curse for dead player", context do
      assert {:error, :invalid_target} ==
               ActionRules.valid(
                 context[:day_state],
                 context[:werewolf_collector],
                 context[:curse_action],
                 context[:dead_players],
                 %Options{}
               )
    end

    test "unable to curse when werewolf_collector is dead", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:day_state],
                 context[:dead_werewolf_collector],
                 context[:curse_action],
                 context[:players],
                 %Options{}
               )
    end

    test "unable to curse in night phase", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:werewolf_collector],
                 context[:curse_action],
                 context[:players],
                 %Options{}
               )
    end

    test "unable to curse when have wrong items", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:day_state],
                 context[:werewolf],
                 context[:curse_action],
                 context[:players],
                 %Options{}
               )
    end
  end

  describe "valid/3 werewolf_mage" do
    setup [
      :transform_action,
      :player,
      :werewolf_mage,
      :dead_werewolf_mage,
      :werewolf,
      :day_state,
      :night_state,
      :players,
      :dead_players
    ]

    test "when able to transform, returns ok tuple", context do
      action = context[:transform_action]

      assert {:ok, action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:werewolf_mage],
                 action,
                 context[:players],
                 %Options{}
               )
    end

    test "unable to transform from dead player", context do
      assert {:error, :invalid_target} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:werewolf_mage],
                 context[:transform_action],
                 context[:dead_players],
                 %Options{}
               )
    end

    test "unable to transform when werewolf_mage is dead", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:dead_werewolf_mage],
                 context[:transform_action],
                 context[:players],
                 %Options{}
               )
    end

    test "unable to transform in day phase", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:day_state],
                 context[:werewolf_mage],
                 context[:transform_action],
                 context[:players],
                 %Options{}
               )
    end

    test "unable to transform when have wrong items", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:werewolf],
                 context[:transform_action],
                 context[:players],
                 %Options{}
               )
    end
  end

  describe "valid/3 gravedigger" do
    setup [
      :disentomb_action,
      :player,
      :gravedigger,
      :dead_gravedigger,
      :werewolf,
      :day_state,
      :night_state,
      :players,
      :dead_players
    ]

    test "when able to disentomb, returns ok tuple", context do
      action = context[:disentomb_action]

      assert {:ok, action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:gravedigger],
                 action,
                 context[:dead_players],
                 %Options{}
               )
    end

    test "unable to disentomb from alive player", context do
      assert {:error, :invalid_target} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:gravedigger],
                 context[:disentomb_action],
                 context[:players],
                 %Options{}
               )
    end

    test "unable to disentomb when gravedigger is dead", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:dead_gravedigger],
                 context[:disentomb_action],
                 context[:dead_players],
                 %Options{}
               )
    end

    test "unable to disentomb in day phase", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:day_state],
                 context[:gravedigger],
                 context[:disentomb_action],
                 context[:dead_players],
                 %Options{}
               )
    end

    test "unable to disentomb when have wrong items", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:werewolf],
                 context[:disentomb_action],
                 context[:dead_players],
                 %Options{}
               )
    end
  end

  describe "valid/3 judge" do
    setup [
      :overrule_action,
      :player,
      :judge,
      :dead_judge,
      :werewolf,
      :day_state,
      :night_state,
      :players,
      :dead_players
    ]

    test "when able to overrule, returns ok tuple", context do
      action = context[:overrule_action]

      assert {:ok, action} ==
               ActionRules.valid(
                 context[:day_state],
                 context[:judge],
                 action,
                 context[:players],
                 %Options{}
               )
    end

    test "unable to overrule for dead player", context do
      assert {:error, :invalid_target} ==
               ActionRules.valid(
                 context[:day_state],
                 context[:judge],
                 context[:overrule_action],
                 context[:dead_players],
                 %Options{}
               )
    end

    test "unable to overrule when judge is dead", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:day_state],
                 context[:dead_judge],
                 context[:overrule_action],
                 context[:players],
                 %Options{}
               )
    end

    test "unable to overrule in night phase", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:judge],
                 context[:overrule_action],
                 context[:players],
                 %Options{}
               )
    end

    test "unable to overrule when have wrong items", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:day_state],
                 context[:werewolf],
                 context[:overrule_action],
                 context[:players],
                 %Options{}
               )
    end
  end

  describe "valid/3 lawyer" do
    setup [
      :defend_action,
      :player,
      :lawyer,
      :dead_lawyer,
      :werewolf,
      :day_state,
      :night_state,
      :players,
      :dead_players
    ]

    test "when able to defend, returns ok tuple", context do
      action = context[:defend_action]

      assert {:ok, action} ==
               ActionRules.valid(
                 context[:day_state],
                 context[:lawyer],
                 action,
                 context[:players],
                 %Options{}
               )
    end

    test "unable to defend for dead player", context do
      assert {:error, :invalid_target} ==
               ActionRules.valid(
                 context[:day_state],
                 context[:lawyer],
                 context[:defend_action],
                 context[:dead_players],
                 %Options{}
               )
    end

    test "unable to defend when lawyer is dead", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:day_state],
                 context[:dead_lawyer],
                 context[:defend_action],
                 context[:players],
                 %Options{}
               )
    end

    test "unable to defend in night phase", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:night_state],
                 context[:lawyer],
                 context[:defend_action],
                 context[:players],
                 %Options{}
               )
    end

    test "unable to defend when have wrong items", context do
      assert {:error, :invalid_action} ==
               ActionRules.valid(
                 context[:day_state],
                 context[:werewolf],
                 context[:overrule_action],
                 context[:players],
                 %Options{}
               )
    end
  end
end
