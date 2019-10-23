defmodule Werewolf.GameServerTest do
  use ExUnit.Case
  alias Werewolf.GameServer

  describe "max players are added, assigns roles, launches game, village win" do
    test "successfully goes through game" do
      {game, players} = setup_game(:day)
      assert_village_win_when_werewolves_killed(game, players)
      clear_ets()
    end
  end

  describe "max players are added, assigns roles, launches game, werewolf win" do
    test "successfully goes through game" do
      {game, players} = setup_game(:day)
      assert_werewolf_win_when_villagers_killed(game, players)
      clear_ets()
    end
  end

  describe "ensure phase is ended when timer runs out" do
    test "successfully transitions phase" do
      {game, players} = setup_game(:millisecond)
      :timer.sleep(1)
      {_, _, phase_number, _} = GameServer.end_phase(game)
      assert(phase_number > 2)
      clear_ets()
    end
  end

  describe "ensure ets is able to maintain state if GenServer shuts down" do
    test "maintains state after shutdown" do
      {game, players} = setup_game(:day)
      GameServer.stop(game)
      {:ok, game} = GameServer.start_link(host(), name(), :day, nil, fn _a, _b -> nil end)
      assert {:no_win, :none, 2, _} = GameServer.end_phase(game)
      clear_ets()
    end
  end

  defp add_users(game, player_count) do
    for n <- 2..player_count,
        do:
          {:ok, :add_player, _, _} =
            GameServer.add_player(game, %{username: "test#{n}", id: "test#{n}"})
  end

  defp assert_all_players_have_roles(players) do
    Enum.each(players, fn {_key, player} ->
      assert player.role != :none
    end)
  end

  defp assert_village_win_when_werewolves_killed(game, players) do
    players_by_team(players, :werewolf)
    |> Enum.map(fn {_, werewolf} ->
      # switch to day phase
      GameServer.end_phase(game)
      vote_for_target_and_end_phase(game, players, werewolf)
    end)
    |> assert_correct_win(:village_win)
  end

  defp assert_werewolf_win_when_villagers_killed(game, players) do
    players_by_team(players, :villager)
    |> Enum.reduce_while([], fn {_, villager}, acc ->
      win_status = vote_for_target_and_end_phase(game, players, villager)
      acc = acc ++ [win_status]
      if win_status != :werewolf_win, do: {:cont, acc}, else: {:halt, acc}
    end)
    |> assert_correct_win(:werewolf_win)
  end

  defp assert_correct_win(win_statuses, win_type) do
    assert List.first(win_statuses) == :no_win
    assert List.last(win_statuses) == win_type
  end

  defp assert_game_launches(game, host) do
    assert {:ok, state} = GameServer.launch_game(game, host)
    state
  end

  defp assert_able_to_add_users(game, host) do
    add_users(game, 18)

    assert {:error, :game_full} =
             GameServer.add_player(game, %{username: "too_many", id: "too_many"})
  end

  defp assign_roles_by_making_game_ready(game, host) do
    {:ok, state} = GameServer.game_ready(game, host)
    state.game.players
  end

  defp host() do
    %{username: "test1", id: "test1"}
  end

  defp setup_game(phase_length) do
    clear_ets()
    {:ok, game} = GameServer.start_link(host(), name(), phase_length, nil, fn _a, _b -> nil end)
    assert_able_to_add_users(game, host())
    assert {:ok, :launch_game, state} = GameServer.launch_game(game, host)
    assert_all_players_have_roles(state.game.players)
    {game, state.game.players}
  end

  defp players_by_team(players, type) do
    Enum.filter(players, fn {_, player} ->
      Werewolf.Player.player_team(player.role) == type && player.alive
    end)
  end

  defp vote_for_target_and_end_phase(game, players, target) do
    Enum.each(players, fn {_, player} ->
      GameServer.action(game, user(player.id), target.id, :vote)
    end)

    {win_status, killed_player, _, _} = GameServer.end_phase(game)
    assert target.id == killed_player
    win_status
  end

  defp user(username) do
    %{username: username, id: username}
  end

  defp name() do
    "test game"
  end

  defp clear_ets() do
    :ets.delete(:game_state, name())
  end
end
