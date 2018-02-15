defmodule Werewolf.Support.PlayerTestSetup do
  alias Werewolf.Player

  def user(_context), do: [user: %{username: "tester", id: 1}]
  def alt_user(_context), do: [alt_user: %{username: "tester2", id: 2}]

  def host_player_map(_context), do: [host_player_map: %{1 => %Player{id: 1, host: true}}]
  def regular_player_map(_context), do: [regular_player_map: %{2 => %Player{id: 2, host: false}}]

  def player_map(_context),
    do: [
      player_map: %{
        "villager" => %Player{id: "villager", host: false, role: :villager},
        "werewolf" => %Player{id: "werewolf", host: false, role: :werewolf}
      }
    ]

  def regular_player(_context), do: [regular_player: %Player{id: "tester2", host: false}]

  def players(_context), do: [players: %{"test" => %Player{id: "test", host: false}}]
end
