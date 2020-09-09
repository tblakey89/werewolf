defmodule Werewolf.Support.PlayerTestSetup do
  alias Werewolf.Player
  alias Werewolf.Action

  def user(_context), do: [user: %{username: "tester", id: 1}]
  def alt_user(_context), do: [alt_user: %{username: "tester2", id: 2}]

  def host_player_map(_context), do: [host_player_map: %{1 => %Player{id: 1, host: true}}]
  def regular_player_map(_context), do: [regular_player_map: %{2 => %Player{id: 2, host: false}}]

  def player_map(_context),
    do: [
      player_map: %{
        "villager" => %Player{id: "villager", host: false, actions: %{}, role: :villager},
        "werewolf" => %Player{id: "werewolf", host: false, actions: %{}, role: :werewolf},
        "doctor" => %Player{id: "doctor", host: false, actions: %{}, role: :doctor},
        "detective" => %Player{id: "detective", host: false, actions: %{}, role: :detective}
      }
    ]

  def additional_player_map(_context),
    do: [
      additional_player_map: %{
        "villager" => %Player{id: "villager", host: false, actions: %{}, role: :villager},
        "werewolf" => %Player{id: "werewolf", host: false, actions: %{}, role: :werewolf},
        "doctor" => %Player{id: "doctor", host: false, actions: %{}, role: :doctor},
        "detective" => %Player{id: "detective", host: false, actions: %{}, role: :detective},
        "little_girl" => %Player{id: "little_girl", host: false, actions: %{}, role: :little_girl},
        "devil" => %Player{id: "devil", host: false, actions: %{}, role: :devil},
        "hunter" => %Player{id: "hunter", host: false, actions: %{}, role: :hunter},
        "hunter_action" => %Player{
          id: "hunter_action",
          host: false,
          actions: %{1 => %{hunt: %Action{type: :hunt, target: "detective"}}},
          role: :hunter
        }
      }
    ]

  def regular_player(_context), do: [regular_player: %Player{id: "tester2", host: false}]

  def players(_context), do: [players: %{"test" => %Player{id: "test", host: false}}]
end
