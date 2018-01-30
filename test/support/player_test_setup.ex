defmodule Werewolf.Support.PlayerTestSetup do
  alias Werewolf.Player

  def user(_context), do: [user: %{username: "tester"}]
  def alt_user(_context), do: [alt_user:  %{username: "tester2"}]

  def host_player_map(_context), do: [host_player_map: %{"tester" => %Player{name: "tester", host: true}}]
  def regular_player_map(_context), do: [regular_player_map: %{"tester2" => %Player{name: "tester2", host: false}}]
  def player_map(_context), do: [player_map: %{"villager" => %Player{name: "villager", host: false, role: :villager},
                                               "werewolf" => %Player{name: "werewolf", host: false, role: :werewolf}}]

  def regular_player(_context), do: [regular_player: %Player{name: "tester2", host: false}]

  def players(_context), do: [players: %{"test" => %Player{name: "test", host: false}}]
end
