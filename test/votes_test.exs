defmodule Werewolf.VotesTest do
  use ExUnit.Case
  alias Werewolf.{Action, Votes}

  describe "count_from_actions/1" do
    setup [:votes, :not_all_votes]

    test "counts votes correctly", context do
      {:ok, vote_count, winner} = Votes.count_from_actions(context[:votes])
      assert vote_count["user"] == 2
      assert vote_count["user2"] == 1
      assert winner == "user"
    end

    test "ignores not voting actions", context do
      {:ok, vote_count, winner} = Votes.count_from_actions(context[:not_all_votes])
      assert vote_count["user"] == 1
      assert vote_count["user2"] == 1
      assert winner == :none
    end
  end

  defp inspect_player(target), do: %Action{type: :inspect, target: target}

  defp not_all_votes(_context), do: [not_all_votes: [vote("user"), inspect_player("user"), vote("user2")]]

  defp votes(_context), do: [votes: [vote("user"), vote("user"), vote("user2")]]

  defp vote(target), do: %{vote: %Action{type: :vote, target: target}}
end
