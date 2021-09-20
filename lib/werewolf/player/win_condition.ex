defmodule Werewolf.Player.WinCondition do
  alias Werewolf.Player

  def by_team do
    %{
      werewolf: :werewolf,
      villager: :villager,
      werewolf_aux: :werewolf,
      fool: :fool
    }
  end
end
