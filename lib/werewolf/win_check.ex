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
     |> by_last_lovers(players)
     |> by_remaining_players(players)
     |> lovers_survived_win(players)}
  end

  defp by_last_lovers(wins, players) do
    case lover_different_team_win?(players) && alive_players_count(players) == 2 do
      true -> [:lover_win | wins]
      false -> wins
    end
  end

  defp by_remaining_players(wins, players) do
    team_count = by_team(players)

    cond do
      team_count[:werewolf] == 0 && team_count[:villager] == 0 ->
        [:tie | wins]

      team_count[:werewolf] == 0 ->
        [:village_win | wins]

      team_count[:werewolf] >= team_count[:villager] && !lover_win?(wins) ->
        [:werewolf_win | wins]

      true ->
        wins
    end
  end

  defp lovers_survived_win([] = wins, _), do: wins

  defp lovers_survived_win(wins, players) do
    case lovers_alive?(players) && village_win?(wins) && !lover_win?(wins) do
      true -> [:lover_win | wins]
      false -> wins
    end
  end

  defp by_team(players) do
    Enum.filter(players, fn {_, player} -> player.alive end)
    |> Enum.reduce(%{villager: 0, werewolf: 0}, fn {_key, %{role: role}}, acc ->
      Map.update!(acc, @team_conversion[Player.player_team(role)], &(&1 + 1))
    end)
  end

  defp alive_players_count(players) do
    Enum.count(players, fn {_, player} -> player.alive end)
  end

  defp werewolf_lover?(players) do
    Enum.any?(
      players,
      fn {_, player} -> player.team == :werewolf && player.lover && player.alive end
    )
  end

  defp lovers_alive?(players) do
    Enum.count(players, fn {_, player} -> player.alive && player.lover end) == 2
  end

  defp lover_win?(wins) do
    Enum.member?(wins, :lover_win)
  end

  defp village_win?(wins) do
    Enum.member?(wins, :village_win)
  end

  defp lover_different_team_win?(players) do
    Enum.reduce(players, MapSet.new(), fn {_, player}, acc ->
      case player.alive && player.lover do
        true -> MapSet.put(acc, player.team)
        false -> acc
      end
    end)
    |> Enum.count() == 2
  end
end
