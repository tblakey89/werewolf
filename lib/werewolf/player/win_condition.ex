defmodule Werewolf.Player.WinCondition do
  alias Werewolf.Player

  def by_team do
    %{
      werewolf: :werewolf_win,
      villager: :village_win,
      werewolf_aux: :werewolf_win,
      fool: :fool_win
    }
  end
end
