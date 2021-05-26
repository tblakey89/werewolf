defmodule Werewolf.Action.VoteTest do
  use ExUnit.Case
  alias Werewolf.{Action, Player, KillTarget}
  import Werewolf.Support.PlayerTestSetup

  describe "count_from_actions/1" do
    setup [:vote_player_map, :player_map]

    test "counts votes correctly", context do
      {:ok, vote_count, winner} = Action.Vote.count_from_actions(context[:vote_player_map], 1)
      assert vote_count["werewolf"] == 3
      assert vote_count["villager"] == 1
      assert winner == "werewolf"
    end

    test "ignores not voting actions", context do
      players = context[:vote_player_map]
      players = put_in(players["villager"].actions, %{})
      players = put_in(players["detective"].actions, %{})

      {:ok, vote_count, winner} = Action.Vote.count_from_actions(players, 1)
      assert vote_count["werewolf"] == 1
      assert vote_count["villager"] == 1
      assert winner == :none
    end

    test "no votes", context do
      {:ok, vote_count, winner} = Action.Vote.count_from_actions(context[:player_map], 1)
      assert winner == :none
    end
  end

  describe "resolve/5" do
    setup [:player_map, :additional_player_map]

    test "sets player to alive false", context do
      players = add_vote(context[:player_map], 1, "werewolf", "villager")
      {:ok, players, win, targets} = Action.Vote.resolve(players, 1)
      assert players["villager"].alive == false
      assert Enum.at(targets, 0).target == "villager"
      assert win == nil
      players = add_vote(context[:player_map], 2, "werewolf", "detective")
      {:ok, players, win, targets} = Action.Vote.resolve(players, 2)
      assert Enum.at(targets, 0).target == "detective"
      assert players["detective"].alive == false
      assert win == nil
    end

    test "sets target as none when no votes", context do
      players = add_vote(context[:player_map], 1, "werewolf", "villager")
      {:ok, players, win, targets} = Action.Vote.resolve(context[:player_map], 1)
      assert targets == []
    end

    test "overrules and kills another player during day", context do
      players = add_vote(context[:player_map], 2, "werewolf", "villager")

      {:ok, players, win, targets} =
        Action.Vote.resolve(players, 2, [], [], [
          KillTarget.new(:overrule, "detective")
        ])

      assert players["villager"].alive == true
      assert length(targets) == 1
      assert Enum.at(targets, 0).target == "detective"
    end

    test "overrules and kills another player during day when no vote target", context do
      {:ok, players, win, targets} =
        Action.Vote.resolve(context[:player_map], 2, [], [], [
          KillTarget.new(:overrule, "detective")
        ])

      assert players["villager"].alive == true
      assert length(targets) == 1
      assert Enum.at(targets, 0).target == "detective"
      assert win == nil
    end

    test "overrules and kills fool during day", context do
      players = add_vote(context[:additional_player_map], 2, "werewolf", "villager")

      {:ok, players, win, targets} =
        Action.Vote.resolve(players, 2, [], [], [
          KillTarget.new(:overrule, "fool")
        ])

      assert players["villager"].alive == true
      assert length(targets) == 1
      assert Enum.at(targets, 0).target == "fool"
      assert win == :fool_win
    end

    test "overrules and kills another player, ignores defence during day", context do
      players = add_vote(context[:player_map], 2, "werewolf", "villager")

      {:ok, players, win, targets} =
        Action.Vote.resolve(players, 2, [], ["villager"], [
          KillTarget.new(:overrule, "detective")
        ])

      assert players["villager"].alive == true
      assert length(targets) == 1
      assert Enum.at(targets, 0).target == "detective"
    end

    test "defends and no player is killed during day", context do
      players = add_vote(context[:player_map], 2, "werewolf", "villager")
      {:ok, players, win, targets} = Action.Vote.resolve(players, 2, [], ["villager"], [])

      assert players["villager"].alive == true
      assert length(targets) == 1
      assert Enum.at(targets, 0).target == "villager"
    end

    test "not update players when no target", context do
      {:ok, players, _, targets} = Action.Vote.resolve(context[:player_map], 1)
      assert targets == []
      assert players == context[:player_map]
    end

    test "not update players when target equals heal target", context do
      players = add_vote(context[:player_map], 1, "werewolf", "villager")
      {:ok, players, _, targets} = Action.Vote.resolve(players, 1, ["villager"])

      assert targets == []
      assert players["villager"].alive == true
    end

    test "sets player to alive false when heal target different", context do
      players = add_vote(context[:player_map], 1, "werewolf", "villager")
      {:ok, players, _, targets} = Action.Vote.resolve(players, 1, ["detective"])

      assert players["villager"].alive == false
      assert length(targets) == 1
    end

    test "a fool win if killed on day phase", context do
      players = add_vote(context[:additional_player_map], 2, "werewolf", "fool")
      {:ok, players, win, targets} = Action.Vote.resolve(players, 2)

      assert players["fool"].alive == false
      assert win == :fool_win
    end

    test "not a fool win if killed on night phase", context do
      players = add_vote(context[:additional_player_map], 1, "werewolf", "fool")
      {:ok, players, win, targets} = Action.Vote.resolve(players, 1)

      assert players["fool"].alive == false
      assert win == nil
    end
  end

  defp add_vote(players, phase_number, player, target) do
    {:ok, player} = Player.add_action(players[player], phase_number, Action.new(:vote, target))
    put_in(players[player], player)
  end

  defp inspect_player(target), do: %Action{type: :inspect, target: target}

  defp not_all_votes(_context),
    do: [not_all_votes: [vote("user"), inspect_player("user"), vote("user2")]]

  defp votes(_context), do: [votes: [vote("user"), vote("user"), vote("user2")]]

  defp vote(target), do: %{vote: %Action{type: :vote, target: target}}

  def vote_player_map(_context),
    do: [
      vote_player_map: %{
        "villager" => %Player{
          id: "villager",
          host: false,
          actions: %{
            1 => %{
              vote: %Action{type: :vote, target: "werewolf"}
            }
          },
          role: :villager
        },
        "werewolf" => %Player{
          id: "werewolf",
          host: false,
          actions: %{
            1 => %{
              vote: %Action{type: :vote, target: "villager"}
            }
          },
          role: :werewolf
        },
        "doctor" => %Player{
          id: "doctor",
          host: false,
          actions: %{
            1 => %{
              vote: %Action{type: :vote, target: "werewolf"}
            }
          },
          role: :doctor
        },
        "detective" => %Player{
          id: "detective",
          host: false,
          actions: %{
            1 => %{
              vote: %Action{type: :vote, target: "werewolf"}
            }
          },
          role: :detective
        }
      }
    ]
end
