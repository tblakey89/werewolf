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

  def usable?(item_type, items) do
    Enum.any?(items, fn item ->
      item.type == item_type && remaining_uses_left?(item.remaining_uses)
    end)
  end

  defp remaining_uses_left?(:infinite), do: true
  defp remaining_uses_left?(uses) when uses > 0, do: true
  defp remaining_uses_left?(_), do: false
end
