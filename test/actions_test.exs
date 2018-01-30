defmodule Werewolf.ActionRulesTest do
  use ExUnit.Case
  import Werewolf.Support.ActionsTestSetup
  alias Werewolf.ActionRules

  describe "valid/3 voting in day phase" do
    setup [:vote_action, :invalid_vote, :player, :dead_player, :day_state, :night_state]

    test "when able to vote, returns ok tuple", context do
      action = context[:vote_action]
      assert {:ok, action} == ActionRules.valid(context[:day_state], context[:player], action)
    end

    test "unable to vote for dead player", context do
      action = context[:invalid_vote]
      assert {:error, :invalid_target} == ActionRules.valid(context[:day_state], context[:player], action)
    end

    test "unable to vote when player is dead", context do
      action = context[:vote_action]
      assert {:error, :invalid_action} == ActionRules.valid(context[:day_state], context[:dead_player], action)
    end

    test "unable to vote at night", context do
      action = context[:vote_action]
      assert {:error, :invalid_action} == ActionRules.valid(context[:night_state], context[:player], action)
    end
  end

  describe "valid/3 werewolf" do
    setup [:vote_action, :invalid_vote, :player, :werewolf, :dead_werewolf, :day_state, :night_state]

    test "when able to vote, returns ok tuple", context do
      action = context[:vote_action]
      assert {:ok, action} == ActionRules.valid(context[:night_state], context[:werewolf], action)
    end

    test "unable to vote for dead player", context do
      action = context[:invalid_vote]
      assert {:error, :invalid_target} == ActionRules.valid(context[:night_state], context[:werewolf], action)
    end

    test "unable to vote when werewolf is dead", context do
      action = context[:vote_action]
      assert {:error, :invalid_action} == ActionRules.valid(context[:night_state], context[:dead_werewolf], action)
    end
  end
end
