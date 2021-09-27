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

  def win_condition_from_lycan_curse(%Player{lover: true} = player) do
    player.win_condition
  end

  def win_condition_from_lycan_curse(_) do
    :werewolf_win
  end
end
