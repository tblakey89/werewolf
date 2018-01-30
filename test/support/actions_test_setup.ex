defmodule Werewolf.Support.ActionsTestSetup do
  alias Werewolf.{Action, Rules, Player}

  def vote_action(_context), do: [vote_action: %Action{type: :vote, target: %{name: "target", alive: true}}]

  def invalid_vote(_context), do: [invalid_vote: %Action{type: :vote, target: %{name: "target", alive: false}}]

  def player(_context), do: [player: %Player{host: false, alive: true, name: "test"}]

  def dead_player(_context), do: [dead_player: %Player{host: false, alive: false, name: "test"}]

  def werewolf(_context), do: [werewolf: %Player{host: false, alive: true, name: "test", role: :werewolf}]

  def dead_werewolf(_context), do: [dead_werewolf: %Player{host: false, alive: false, name: "test", role: :werewolf}]

  def day_state(_context), do: [day_state: %Rules{state: :day_phase}]

  def night_state(_context), do: [night_state: %Rules{state: :night_phase}]
end
