defmodule WerewolfTest do
  use ExUnit.Case
  doctest Werewolf

  test "greets the world" do
    assert Werewolf.hello() == :world
  end
end
