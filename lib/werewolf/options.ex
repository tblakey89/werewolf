defmodule Werewolf.Options do
  alias __MODULE__

  @enforce_keys []
  @derive Jason.Encoder
  defstruct reveal_role: true,
            reveal_type_of_death: true,
            allow_action_changes: true,
            allow_no_kill_vote: false
  use ExConstructor
end
