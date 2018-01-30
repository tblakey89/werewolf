defmodule Werewolf.Action do
  alias __MODULE__

  @enforce_keys [:type, :target]
  defstruct [:type, :target, option: :none]

  def new(type, target) do
    %Action{type: type, target: target}
  end
end
