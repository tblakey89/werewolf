defmodule Werewolf.Action.Vote do
  import Guard, only: [is_even: 1]
  alias Werewolf.{Action, KillTarget, Player}

  def count_from_actions(players, phase_number) do
    phase_actions(players, phase_number)
    |> Enum.filter(fn action -> Map.has_key?(action, :vote) end)
    |> count_votes_per_target()
    |> vote_response()
  end

  def resolve(
        players,
        phase_number,
        heal_targets \\ [],
        defend_targets \\ [],
        overrule_targets \\ []
      ) do
    {:ok, votes, target} = count_from_actions(players, phase_number)

    kill_player(players, phase_number, target, heal_targets, defend_targets, overrule_targets)
  end

  defp kill_player(players, phase_number, target, _, _, overrule_targets)
       when is_even(phase_number) and length(overrule_targets) > 0 do
    {:ok, players, nil, overrule_targets}

    case Enum.any?(overrule_targets, fn kill_target ->
           players[kill_target.target].role == :fool
         end) do
      true -> {:ok, players, :fool_win, overrule_targets}
      _ -> {:ok, players, nil, overrule_targets}
    end
  end

  defp kill_player(players, _, :none, _, _, _), do: {:ok, players, nil, []}

  defp kill_player(players, _, "no_kill", _, _, _),
    do: {:ok, players, nil, []}

  defp kill_player(players, phase_number, target, _, defend_targets, [])
       when is_even(phase_number) do
    case Enum.member?(defend_targets, target) do
      true ->
        {:ok, players, nil, [KillTarget.new(:defend, target)]}

      false ->
        players = put_in(players[target].alive, false)

        case players[target].role do
          :fool -> {:ok, players, :fool_win, [KillTarget.new(:vote, target)]}
          _ -> {:ok, players, nil, [KillTarget.new(:vote, target)]}
        end
    end
  end

  defp kill_player(players, phase_number, target, heal_targets, _, _) do
    case Enum.member?(heal_targets, target) do
      true ->
        {:ok, players, nil, []}

      false ->
        player = players[target]

        case player.lycan_curse do
          true ->
            {:ok, add_lycan_curse_action(players, player, phase_number), nil,
             [KillTarget.new(:new_werewolf, target)]}

          false ->
            players = put_in(players[target].alive, false)

            {:ok, players, nil, [KillTarget.new(:werewolf, target)]}
        end
    end
  end

  defp phase_actions(players, phase_number) do
    Enum.map(players, fn {_, player} -> player.actions end)
    |> Enum.map(fn actions -> actions[phase_number] end)
    |> Enum.reject(fn action -> is_nil(action) end)
  end

  defp count_votes_per_target(vote_actions) do
    Enum.reduce(vote_actions, %{}, fn action, acc ->
      vote = action.vote
      votes = votes_provided(vote)
      Map.update(acc, vote.target, votes, &(&1 + votes))
    end)
  end

  defp tie_check({winning_user, highest_value}, votes) do
    count = Enum.count(votes, fn {_, value} -> value == highest_value end)

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
    Enum.max_by(votes, fn {_, value} -> value end, fn -> {:none, 0} end)
    |> tie_check(votes)
  end

  defp add_lycan_curse_action(players, player, phase_number) do
    {:ok, player_with_action} =
      Player.add_action(player, phase_number, Action.new(:lycan_curse, player.id))

    # players =
    #   Enum.reduce(players, players, fn {id, current_player}, acc_players ->
    #     case current_player.team do
    #       :werewolf ->
    #         {:ok, werewolf_with_action} =
    #           Player.add_action(
    #             current_player,
    #             phase_number,
    #             Action.new(:new_werewolf, player.id, player.id)
    #           )
    #
    #         put_in(players[id], werewolf_with_action)
    #
    #       _ ->
    #         acc_players
    #     end
    #   end)

    put_in(
      players[player.id],
      %{
        player_with_action
        | role: :werewolf,
          team: :werewolf,
          win_condition: Player.WinCondition.win_condition_from_lycan_curse(player_with_action)
      }
    )
  end
end
