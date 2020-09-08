defmodule Werewolf.Support.ActionsTestSetup do
  alias Werewolf.{Action, Rules, Player}

  def vote_action(_context), do: [vote_action: %Action{type: :vote, target: "target"}]

  def invalid_vote(_context), do: [invalid_vote: %Action{type: :vote, target: "target"}]

  def heal_action(_context), do: [heal_action: %Action{type: :heal, target: "target"}]

  def inspect_action(_context), do: [inspect_action: %Action{type: :inspect, target: "target"}]

  def player(_context), do: [player: %Player{host: false, alive: true, id: "test"}]

  def dead_player(_context), do: [dead_player: %Player{host: false, alive: false, id: "test"}]

  def werewolf(_context),
    do: [werewolf: %Player{host: false, alive: true, id: "test", role: :werewolf}]

  def dead_werewolf(_context),
    do: [dead_werewolf: %Player{host: false, alive: false, id: "test", role: :werewolf}]

  def doctor(_context), do: [doctor: %Player{host: false, alive: true, id: "test", role: :doctor}]

  def dead_doctor(_context),
    do: [dead_doctor: %Player{host: false, alive: false, id: "test", role: :doctor}]

  def detective(_context),
    do: [detective: %Player{host: false, alive: true, id: "test", role: :detective}]

  def dead_detective(_context),
    do: [dead_detective: %Player{host: false, alive: false, id: "test", role: :detective}]

    def little_girl(_context),
      do: [little_girl: %Player{host: false, alive: true, id: "test", role: :little_girl}]

    def dead_little_girl(_context),
      do: [dead_little_girl: %Player{host: false, alive: false, id: "test", role: :little_girl}]

  def day_state(_context), do: [day_state: %Rules{state: :day_phase}]

  def night_state(_context), do: [night_state: %Rules{state: :night_phase}]

  def players(_context),
    do: [players: %{"target" => %Player{id: "target", host: false, alive: true}}]

  def dead_players(_context),
    do: [dead_players: %{"target" => %Player{id: "target", host: false, alive: false}}]
end
