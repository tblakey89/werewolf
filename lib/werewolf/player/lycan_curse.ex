defmodule Werewolf.Player.LycanCurse do
  alias Werewolf.Options

  def assign(
        players,
        %Options{
          allow_lycan_curse: true
        } = options
      ) do
    lycan_player =
      Map.values(players)
      |> Enum.shuffle()
      |> Enum.find(fn player ->
        (player.team == :villager || player.team == :werewolf_aux) && !player.lover
      end)

    case lycan_player do
      nil ->
        players

      _ ->
        Map.put(players, lycan_player.id, %{
          lycan_player
          | lycan_curse: true
        })
    end
  end

  def assign(players, _), do: players
end
