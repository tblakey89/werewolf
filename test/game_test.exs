defmodule Werewolf.GameTest do
  use ExUnit.Case
  alias Werewolf.{Game, Player, Rules, Action}

  describe "new/2" do
    setup [:user]

    test "returns a game struct when given user and valid phase length", context do
      {:ok, game} = Game.new(context[:user], context[:user].id, :day)
      assert game.players[context[:user].id].id == context[:user].id
      assert game.phase_length == :day
    end

    test "returns an error when given an invalid phase length", context do
      assert {:error, :invalid_phase_length} == Game.new(context[:user], context[:user], :year)
    end
  end

  describe "add_player/3" do
    setup [:game, :ready_game, :rules, :other_user, :user]

    test "adds the user to the game player list", context do
      {:ok, game, rules} = Game.add_player(context[:game], context[:other_user], context[:rules])
      assert Enum.count(game.players) == 2
    end

    test "returns updated rules when enough players", context do
      {:ok, game, rules} =
        Game.add_player(context[:ready_game], context[:other_user], context[:rules])

      assert rules.state != context[:rules].state
    end

    test "fails to add user if wrong state", context do
      day_phase_rules = %{context[:rules] | state: :day_phase}

      assert {:error, :invalid_action} ==
               Game.add_player(context[:game], context[:other_user], day_phase_rules)
    end

    test "fails to add user if user exists", context do
      assert {:error, :user_already_joined} ==
               Game.add_player(context[:game], context[:user], context[:rules])
    end
  end

  describe "launch_game/3" do
    setup [:ready_game, :ready_rules, :rules, :user, :game, :other_user]

    test "when state is ready, able to launch game", context do
      {:ok, game, rules} =
        Game.launch_game(context[:ready_game], context[:user], context[:ready_rules])

      assert rules.state == :night_phase
      assert game.phases == 1
      assert game.players[context[:user].id].role != :none
    end

    test "when game is in the wrong state", context do
      {:error, :invalid_action} =
        Game.launch_game(context[:ready_game], context[:user], context[:rules])
    end

    test "when not-host tries to launch game", context do
      {:error, :unauthorized} =
        Game.launch_game(context[:ready_game], context[:other_user], context[:ready_rules])
    end
  end

  describe "action/4" do
    setup [:ready_game, :day_rules, :night_rules, :rules, :user, :vote_action]

    test "successfully performs action, and adds to player", context do
      game = put_in(context[:ready_game].phases, 1)

      {:ok, game} =
        Game.action(
          context[:ready_game],
          context[:user],
          context[:day_rules],
          context[:vote_action]
        )

      assert game.players[context[:user].id].actions[game.phases].vote == context[:vote_action]
    end

    test "when not a valid action for the state", context do
      {:error, :invalid_action} =
        Game.action(
          context[:ready_game],
          context[:user],
          context[:night_rules],
          context[:vote_action]
        )
    end
  end

  describe "end_phase/2" do
    setup [:night_rules, :day_rules, :finished_game, :rules]

    test "when game won, sends win atom, and updates state", context do
      {:ok, game, rules, target, win_status} =
        Game.end_phase(context[:finished_game], context[:day_rules])

      assert game.players["test2"].alive == false
      assert rules.state == :game_over
      assert target == "test2"
      assert win_status == :village_win
    end

    test "when votes tie, sends no_win atom, and updates state", context do
      finished_game = context[:finished_game]
      finished_game = put_in(finished_game.players["test2"].actions[1].vote.target, "test1")
      finished_game = put_in(finished_game.players["test3"].actions[1], nil)
      {:ok, game, rules, target, win_status} = Game.end_phase(finished_game, context[:day_rules])
      assert game.players["test2"].alive == true
      assert rules.state == :night_phase
      assert target == :none
      assert win_status == :no_win
      assert game.phases == 2
    end

    test "when wrong state, unable to end phase", context do
      {:error, :invalid_action} = Game.end_phase(context[:finished_game], context[:rules])
    end
  end

  describe "current_vote_count/1" do
    setup [:finished_game]

    test "returns correct vote count", context do
      finished_game = context[:finished_game]
      assert Game.current_vote_count(finished_game) == {3, "test2"}
    end
  end

  defp ready_game(_context) do
    [ready_game: %Game{id: 0, players: generate_players(), phase_length: :day, phases: 0}]
  end

  defp game(_context), do: [game: create_game(%{username: "test1", id: "test1"}, :day)]
  defp other_user(_context), do: [other_user: %{username: "test99", id: "test99"}]
  defp rules(_context), do: [rules: Rules.new()]
  defp ready_rules(_context), do: [ready_rules: %Rules{state: :ready}]
  defp day_rules(_context), do: [day_rules: %Rules{state: :day_phase}]
  defp night_rules(_context), do: [night_rules: %Rules{state: :night_phase}]
  defp user(_context), do: [user: %{username: "test1", id: "test1"}]
  defp vote_action(_context), do: [vote_action: %Action{type: :vote, target: "test2"}]

  defp finished_game(_context) do
    [
      finished_game: %Game{
        id: 1,
        phases: 1,
        phase_length: :day,
        players: %{
          "test1" => %Player{
            id: "test1",
            alive: true,
            host: true,
            role: :villager,
            actions: %{
              1 => %{
                vote: %Action{
                  type: :vote,
                  target: "test2"
                }
              }
            }
          },
          "test2" => %Player{
            id: "test2",
            alive: true,
            host: false,
            role: :werewolf,
            actions: %{
              1 => %{
                vote: %Action{
                  type: :vote,
                  target: "test2"
                }
              }
            }
          },
          "test3" => %Player{
            id: "test3",
            alive: true,
            host: false,
            role: :villager,
            actions: %{
              1 => %{
                vote: %Action{
                  type: :vote,
                  target: "test2"
                }
              }
            }
          }
        }
      }
    ]
  end

  defp create_game(user, phase_length) do
    {:ok, game} = Game.new(user, user.id, phase_length)
    game
  end

  defp generate_players() do
    players = %{"test1" => %Player{id: "test1", host: true}}
    users = for n <- 2..8, do: %Player{id: "test#{n}", host: false}

    Enum.reduce(users, players, fn player, acc ->
      put_in(acc[player.id], player)
    end)
  end
end
