defmodule Werewolf.WinCheck do
  alias Werewolf.Player

  def by_remaining_players(:fool_win, _players), do: {:ok, :fool_win}

  def by_remaining_players(_existing_win_status, players) do
    team_count = by_team(players)

    {:ok,
     cond do
       team_count[:werewolf] == 0 && team_count[:villager] == 0 -> :tie
       team_count[:werewolf] == 0 -> :village_win
       team_count[:werewolf] >= team_count[:villager] -> :werewolf_win
       true -> :no_win
     end}
  end

  defp by_team(players) do
    Enum.filter(players, fn {_, player} -> player.alive end)
    |> Enum.reduce(%{villager: 0, werewolf: 0}, fn {_key, %{role: role}}, acc ->
      Map.update!(acc, Player.player_team(role), &(&1 + 1))
    end)
  end
end
