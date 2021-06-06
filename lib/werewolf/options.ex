defmodule Werewolf.Options do
  alias __MODULE__

  @enforce_keys []
  @derive Jason.Encoder
  defstruct reveal_role: true,
            reveal_type_of_death: true,
            allow_action_changes: true,
            allow_no_kill_vote: false

  def new(reveal_role \\ true, reveal_type_of_death \\ true) do
    %Options{reveal_role: reveal_role, reveal_type_of_death: reveal_type_of_death}
  end
end
