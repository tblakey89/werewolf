defmodule Werewolf.Options do
  alias __MODULE__

  @enforce_keys []
  @derive Jason.Encoder
  defstruct reveal_role: true,
            reveal_type_of_death: true,
            allow_action_changes: true,
            allow_no_kill_vote: true,
            allow_claim_role: true,
            allow_host_end_phase: true,
            display_votes: true,
            allow_host_end_game: true,
            reveal_role_on_inspect: true

  use ExConstructor

  def check(options, :end_phase, :automated), do: :ok

  def check(options, :end_phase, _) do
    case options.allow_host_end_phase do
      true -> :ok
      false -> {:error, :allow_host_end_phase_not_enabled}
    end
  end

  def check(options, :end_game, _) do
    case options.allow_host_end_game do
      true -> :ok
      false -> {:error, :allow_host_end_game_not_enabled}
    end
  end

  def check(options, :claim_role, _) do
    case options.allow_claim_role do
      true -> :ok
      false -> {:error, :allow_claim_role_not_enabled}
    end
  end

  def check(options, :change_action, _) do
    case options.allow_action_changes do
      true -> :ok
      false -> {:error, :allow_action_changes_not_enabled}
    end
  end
end
