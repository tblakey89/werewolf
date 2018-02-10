defmodule Werewolf.PhaseTest do
  use ExUnit.Case
  alias Werewolf.Phase

  @hour 60 * 60 * 1000

  describe "calculate_end_of_phase_unix/1" do
    test "successfully calculates", context do
      time_now = DateTime.to_unix(DateTime.utc_now)
      end_of_phase = Phase.calculate_end_of_phase_unix(:hour)
      assert time_now < end_of_phase
    end
  end

  describe "milliseconds_till_end_of_phase/1" do
    test "when end_of_phase is after now" do
      time_till_end = Phase.milliseconds_till_end_of_phase(one_hour_from_now())
      assert time_till_end > 0
    end

    test "when end_of_phase has already passed" do
      time_till_end = Phase.milliseconds_till_end_of_phase(one_hour_before_now())
      assert time_till_end == 0
    end
  end

  defp one_hour_from_now() do
    DateTime.to_unix(DateTime.utc_now(), :millisecond) + @hour
  end

  defp one_hour_before_now() do
    DateTime.to_unix(DateTime.utc_now(), :millisecond) - @hour
  end
end
