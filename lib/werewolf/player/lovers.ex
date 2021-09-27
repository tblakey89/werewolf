defmodule Werewolf.Player.Lovers do
  alias Werewolf.{Player, Options}

  def assign(
        players,
        %Options{
          allow_lovers: true
        } = options
      ) do
    shuffled_players = Enum.shuffle(Map.values(players))
    first_player = Enum.at(shuffled_players, 0)
    second_player = Enum.at(shuffled_players, 1)

    case allowed_combination(first_player, second_player) do
      true -> set_lover_bool(players, [first_player, second_player])
      false -> Player.Lovers.assign(players, options)
    end
  end

  def assign(players, _), do: players

  defp set_lover_bool(players, lovers) do
    Enum.reduce(lovers, players, fn player, acc ->
      Map.put(acc, player.id, %{
        player
        | lover: true,
          win_condition: :lover_win
      })
    end)
  end

  defp allowed_combination(first_player, second_player) do
    first_team = Player.player_team(first_player.role)
    second_team = Player.player_team(second_player.role)

    teams = [first_team, second_team]

    Enum.any?(teams, fn team -> team == :villager end) &&
      length(teams -- [:villager, :werewolf]) == 0
  end
end
