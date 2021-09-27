defmodule Werewolf.Action.Suicide do
  alias Werewolf.KillTarget

  def resolve(players, targets) do
    with lovers <- find_lovers(players),
         true <- length(lovers) == 2,
         true <- one_alive_one_dead?(lovers),
         suicide_player <- find_alive_lover(lovers) do
      {:ok,
       put_in(
         players[suicide_player.id].alive,
         false
       ), [KillTarget.new(:suicide, suicide_player.id) | targets]}
    else
      nil -> {:ok, players, targets}
      false -> {:ok, players, targets}
    end
  end

  defp find_lovers(players) do
    Map.values(players)
    |> Enum.filter(fn player ->
      player.lover
    end)
  end

  defp one_alive_one_dead?(players) do
    List.first(players).alive != List.last(players).alive
  end

  defp find_alive_lover(lovers) do
    Enum.find(lovers, & &1.alive)
  end
end
