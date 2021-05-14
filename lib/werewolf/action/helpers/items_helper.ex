defmodule Werewolf.Action.Helpers.ItemsHelper do
  alias Werewolf.Action

  def steal_item([]), do: {nil, []}

  def steal_item(items) do
    [stolen_item | remaining_items] = Enum.shuffle(items)
    {stolen_item, remaining_items}
  end

  def generate_item_result_action(_type, nil, _target), do: nil

  def generate_item_result_action(type, item, target) do
    %Action{type: type, result: item.type, target: target}
  end
end
