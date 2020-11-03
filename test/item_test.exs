defmodule Werewolf.ItemTest do
  use ExUnit.Case
  alias Werewolf.Item

  describe "new/2" do
    test "returns a Item struct with infinite uses when give magnifying glass" do
      assert %Item{type: :magnifying_glass, remaining_uses: :infinite} =
               Item.new(:magnifying_glass)
    end
  end
end
