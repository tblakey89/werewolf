defmodule Werewolf.KillTarget do
  alias __MODULE__

  @enforce_keys [:type, :target]
  @derive Jason.Encoder
  defstruct [:type, :target]

  def new(type, target) do
    %KillTarget{type: type, target: target}
  end

  def to_map(kill_targets) do
    Enum.reduce(kill_targets, %{}, fn kill_target, map ->
      Map.put_new(map, kill_target.type, kill_target.target)
    end)
  end
end
