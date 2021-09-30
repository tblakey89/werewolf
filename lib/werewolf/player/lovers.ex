defmodule Werewolf.Player.Lovers do
  alias Werewolf.{Player, Options}

  def assign(
        players,
        %Options{
          allow_lovers: true
        } = options
      ) do
    team_of_lovers =
      case :rand.uniform(4) do
        4 -> [:villager, :werewolf]
        _ -> [:villager, :villager]
      end

    shuffled_players = Enum.shuffle(Map.values(players))

    first_player =
      Enum.find(shuffled_players, fn player -> player.team == Enum.at(team_of_lovers, 0) end)

    second_player =
      Enum.find(shuffled_players, fn player ->
        player.team == Enum.at(team_of_lovers, 1) && player.id != first_player.id
      end)

    set_lover_bool(players, [first_player, second_player])
  end

  def assign(players, _), do: players

  defp set_lover_bool(players, [nil, _]), do: players

  defp set_lover_bool(players, [_, nil]), do: players

  defp set_lover_bool(players, lovers) do
    Enum.reduce(lovers, players, fn player, acc ->
      Map.put(acc, player.id, %{
        player
        | lover: true,
          win_condition: :lover_win
      })
    end)
  end
end
