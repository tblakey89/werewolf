defmodule Werewolf.KillTarget do
  alias __MODULE__

  @enforce_keys [:type, :target]
  @derive Jason.Encoder
  defstruct [:type, :target]

  def new(type, target) do
    %KillTarget{type: type, target: target}
  end
end
