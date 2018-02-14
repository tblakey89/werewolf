defmodule Werewolf.PlayerRules do

  def host_check(players, user) do
    case Map.has_key?(players, user.id) && is_host?(players[user.id]) do
      true -> :ok
      false -> {:error, :unauthorized}
    end
  end

  def player_check(players, user) do
    case alive?(players, user) do
      true ->{:ok, players[user.id]}
      false -> {:error, :not_in_game}
    end
  end

  def unique_check(players, user) do
    case !Map.has_key?(players, user.id) do
      true -> {:ok, players}
      false -> {:error, :user_already_joined}
    end
  end

  defp alive?(players, user) do
    Map.has_key?(players, user.id) && players[user.id].alive
  end

  defp is_host?(player) do
    player.host
  end

  defp is_user?(player, user) do
    player.name == user.id
  end
end
