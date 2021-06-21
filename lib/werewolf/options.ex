defmodule Werewolf.Options do
  alias __MODULE__

  @enforce_keys []
  @derive Jason.Encoder
  defstruct reveal_role: true,
            reveal_type_of_death: true,
            allow_action_changes: true,
            allow_no_kill_vote: false,
            allow_claim_role: false,
            allow_host_end_phase: false

  use ExConstructor

  def check(options, :end_phase, :automated), do: :ok

  def check(options, :end_phase, _) do
    case options.allow_host_end_phase do
      true -> :ok
      false -> {:error, :allow_host_end_phase_not_enabled}
    end
  end
end
