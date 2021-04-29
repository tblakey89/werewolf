defmodule Werewolf.Item do
  alias __MODULE__

  @enforce_keys [:type, :remaining_uses]
  @derive Jason.Encoder
  defstruct [:type, :remaining_uses]

  @uses_by_type %{
    magnifying_glass: :infinite,
    first_aid_kit: :infinite,
    dead_man_switch: :infinite,
    binoculars: :infinite,
    poison: 1,
    resurrection_scroll: 1,
    crystal_ball: :infinite,
    sword: :infinite,
    lock_pick: 1,
    hammer: 1,
    cursed_relic: :infinite,
    transformation_scroll: :infinite
  }

  @items_to_actions %{
    magnifying_glass: :inspect,
    first_aid_kit: :heal,
    dead_man_switch: :hunt,
    binoculars: :inspect,
    poison: :poison,
    resurrection_scroll: :resurrect,
    crystal_ball: :channel,
    sword: :assassinate,
    lock_pick: :steal,
    hammer: :sabotage,
    cursed_relic: :curse,
    transformation_scroll: :transform
  }

  def new(type) do
    %Item{type: type, remaining_uses: @uses_by_type[type]}
  end

  def usable?(item_type, items) do
    Enum.any?(items, fn item ->
      item.type == item_type && remaining_uses_left?(item.remaining_uses)
    end)
  end

  def use_items(actions, items) do
    Enum.map(items, fn item ->
      case actions[@items_to_actions[item.type]] do
        nil -> item
        action -> Map.put(item, :remaining_uses, calculate_remaining_uses(item.type, item))
      end
    end)
  end

  def includes?(item_types, items) do
    # This should always be two very small lists
    Enum.any?(items, fn item ->
      remaining_uses_left?(item.remaining_uses) &&
        Enum.any?(item_types, fn item_type ->
          item_type == item.type
        end)
    end)
  end

  defp calculate_remaining_uses(_, %Item{remaining_uses: :infinite}), do: :infinite

  defp calculate_remaining_uses(item_type, %Item{type: item_type} = item) do
    item.remaining_uses - 1
  end

  defp calculate_remaining_uses(_, %Item{remaining_uses: uses}), do: uses

  defp remaining_uses_left?(:infinite), do: true
  defp remaining_uses_left?(uses) when uses > 0, do: true
  defp remaining_uses_left?(_), do: false
end
