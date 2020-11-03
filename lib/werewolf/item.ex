defmodule Werewolf.Item do
  alias __MODULE__

  @enforce_keys [:type, :remaining_uses]
  @derive Jason.Encoder
  defstruct [:type, :remaining_uses]

  @uses_by_type %{
    magnifying_glass: :infinite,
    first_aid_kit: :infinite,
    dead_man_switch: :infinite,
    binoculars: :infinite
  }

  def new(type) do
    %Item{type: type, remaining_uses: @uses_by_type[type]}
  end
end
