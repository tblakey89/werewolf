defmodule Werewolf.Action do
  alias __MODULE__

  @enforce_keys [:type, :target]
  @derive Jason.Encoder
  defstruct [:type, :target, :result, :seen, option: :none]

  def new(type, target, result \\ nil) do
    %Action{type: type, target: target, result: result}
  end
end
