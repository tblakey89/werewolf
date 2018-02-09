defmodule Werewolf.GameServerTest do
  use ExUnit.Case
  alias Werewolf.GameServer

  # don't forget to test ETS back up, and database backup, think of others too

  describe "max players are added, assigns roles, launches game, village win" do
    test "successfully goes through game" do
      {game, players} = setup_game()
      assert_village_win_when_werewolves_killed(game, players)
    end
  end

  describe "max players are added, assigns roles, launches game, werewolf win" do
    test "successfully goes through game" do
      {game, players} = setup_game()
      assert_werewolf_win_when_villagers_killed(game, players)
    end
  end

  defp add_users(game, player_count) do
    for n <- 2..player_count, do: GameServer.add_player(game, %{username: "test#{n}"})
  end

  defp assert_all_players_have_roles(players) do
    Enum.each(players, fn({_key, player}) ->
      assert player.role != :none
    end)
  end

  defp assert_village_win_when_werewolves_killed(game, players) do
    players_by_type(players, :werewolf)
    |> Enum.map(fn({_, werewolf}) ->
      # switch to day phase
      GameServer.end_phase(game)
      vote_for_target_and_end_phase(game, players, werewolf)
    end)
    |> assert_correct_win(:village_win)
  end

  defp assert_werewolf_win_when_villagers_killed(game, players) do
    players_by_type(players, :villager)
    |> Enum.map(fn({_, villager}) -> 
      vote_for_target_and_end_phase(game, players, villager)
    end)
    |> assert_correct_win(:werewolf_win)
  end

  defp assert_correct_win(win_statuses, win_type) do
    assert List.first(win_statuses) == :no_win
    assert List.last(win_statuses) == win_type
  end

  defp assert_game_launches(game, host) do
    assert :ok == GameServer.launch_game(game, host)
  end

  defp assert_able_to_add_users(game, host) do
    add_users(game, 18)
    assert {:error, :game_full} = GameServer.add_player(game, %{username: "too_many"})
  end

  defp assign_roles_by_making_game_ready(game, host) do
    {:ok, players} = GameServer.game_ready(game, host)
    players
  end

  defp setup_game() do
    host = %{username: "test1"}
    {:ok, game} = GameServer.start_link(host, :day)
    assert_able_to_add_users(game, host)
    players = assign_roles_by_making_game_ready(game, host)
    assert_all_players_have_roles(players)
    assert_game_launches(game, host)
    {game, players}
  end

  defp players_by_type(players, type) do
    Enum.filter(players, fn({_, player}) ->
      player.role == type && player.alive
    end)
  end

  defp vote_for_target_and_end_phase(game, players, target) do
    Enum.each(players, fn({_, player}) ->
      GameServer.action(game, user(player.name), target.name, :vote)
    end)
    {win_status, target} = GameServer.end_phase(game)
    win_status
  end

  defp user(username) do
    %{username: username}
  end
end
