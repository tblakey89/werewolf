defmodule Werewolf.WinCheck do
  alias Werewolf.Player

  @team_conversion %{
    werewolf_aux: :villager,
    werewolf: :werewolf,
    fool: :villager,
    villager: :villager
  }

  def check_for_wins(:fool_win, _players), do: {:ok, [:fool_win]}

  def check_for_wins(_existing_win_status, players) do
    {:ok,
     []
     |> by_remaining_players(players)}
  end

  defp by_remaining_players(wins, players) do
    team_count = by_team(players)

    cond do
      team_count[:werewolf] == 0 && team_count[:villager] == 0 -> [:tie | wins]
      team_count[:werewolf] == 0 -> [:village_win | wins]
      team_count[:werewolf] >= team_count[:villager] -> [:werewolf_win | wins]
      true -> wins
    end
  end

  defp by_team(players) do
    Enum.filter(players, fn {_, player} -> player.alive end)
    |> Enum.reduce(%{villager: 0, werewolf: 0}, fn {_key, %{role: role}}, acc ->
      Map.update!(acc, @team_conversion[Player.player_team(role)], &(&1 + 1))
    end)
  end
end
