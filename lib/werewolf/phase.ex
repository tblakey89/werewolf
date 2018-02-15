defmodule Werewolf.Phase do
  def calculate_end_of_phase_unix(phase_length) do
    DateTime.to_unix(DateTime.utc_now(), :millisecond) +
      phase_lengths_in_milliseconds()[phase_length]
  end

  def milliseconds_till_end_of_phase(end_time) do
    DateTime.from_unix!(end_time, :millisecond)
    |> DateTime.diff(DateTime.utc_now(), :millisecond)
    |> negative_values_to_zero()
  end

  defp phase_lengths_in_milliseconds() do
    %{
      millisecond: 1,
      second: 1000,
      hour: 60 * 60 * 1000,
      day: 24 * 60 * 60 * 1000
    }
  end

  defp negative_values_to_zero(milliseconds) when milliseconds < 0, do: 0
  defp negative_values_to_zero(milliseconds), do: milliseconds
end
