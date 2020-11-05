defmodule Werewolf.ItemTest do
  use ExUnit.Case
  alias Werewolf.Item

  describe "new/2" do
    test "returns a Item struct with infinite uses when give magnifying glass" do
      assert %Item{type: :magnifying_glass, remaining_uses: :infinite} =
               Item.new(:magnifying_glass)
    end
  end

  describe "usable?/2" do
    test "returns true when item found and has infinite uses" do
      assert Item.usable?(:flower, [%Item{type: :flower, remaining_uses: :infinite}]) == true
    end

    test "returns true when item found and has one use" do
      assert Item.usable?(:flower, [%Item{type: :flower, remaining_uses: 1}]) == true
    end

    test "returns false when item found and has one use" do
      assert Item.usable?(:flower, [%Item{type: :flower, remaining_uses: 0}]) == false
    end

    test "returns false when item not found" do
      assert Item.usable?(:first_aid_kit, [%Item{type: :flower, remaining_uses: :infinite}]) ==
               false
    end
  end

  describe "use_item/2" do
    test "returns infinite remaining uses when it is infinite" do
      assert Enum.at(Item.use_item(:flower, [%Item{type: :flower, remaining_uses: :infinite}]), 0).remaining_uses ==
               :infinite
    end

    test "returns 0 remaining uses when it is 1" do
      assert Enum.at(Item.use_item(:flower, [%Item{type: :flower, remaining_uses: 1}]), 0).remaining_uses ==
               0
    end

    test "returns 1 remaining uses when it is 1, but wrong item" do
      assert Enum.at(Item.use_item(:first_aid_kit, [%Item{type: :flower, remaining_uses: 1}]), 0).remaining_uses ==
               1
    end
  end
end
