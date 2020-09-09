defmodule Guard do
  defguard is_even(value) when is_integer(value) and rem(value, 2) == 0
end
