defmodule Werewolf.Votes do
  alias Werewolf.Action

  def count_from_actions(actions) do
    Enum.filter(actions, fn(action) -> Map.has_key?(action, :vote) end)
    |> count_votes_per_target()
    |> vote_response()
  end

  defp count_votes_per_target(vote_actions) do
    Enum.reduce(vote_actions, %{}, fn(action, acc) ->
      vote = action.vote
      votes = votes_provided(vote)
      Map.update(acc, vote.target, votes, &(&1 + votes))
    end)
  end

  defp tie_check({winning_user, highest_value}, votes) do
    count = Enum.count(votes, fn({_, value}) -> value == highest_value end)
    cond do
      count == 1 -> winning_user
      count > 1 -> :none
      count == 0 -> :none
    end
  end  

  defp votes_provided(%Action{option: :none}), do: 1
  defp votes_provided(%Action{option: :sheriff}), do: 2

  defp vote_response(votes) do
    {:ok, votes, winner(votes)}
  end

  defp winner(votes) when map_size(votes) == 0, do: :none
  defp winner(votes) do
    Enum.max_by(votes, fn({_, value}) -> value end, {:none, 0})
    |> tie_check(votes)
  end
end
