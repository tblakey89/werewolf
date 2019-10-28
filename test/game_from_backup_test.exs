defmodule Werewolf.GameFromBackupTest do
  use ExUnit.Case
  alias Werewolf.GameFromBackup

  describe "convert_game_from_map" do
    setup [:state, :state_from_db]

    test "when passed nil, returns nil" do
      assert GameFromBackup.convert(nil) == nil
    end

    test "when passed state_from_db, returns state", context do
      assert GameFromBackup.convert(context[:state_from_db]) == context[:state]
    end
  end

  defp state_from_db(_context) do
    [
      state_from_db: %{
        "game" => %{
          "end_phase_unix_time" => nil,
          "id" => 178,
          "phase_length" => "day",
          "phases" => 0,
          "win_status" => "werewolf_win",
          "targets" => %{
            "1" => [
              %{
                "type" => "werewolf",
                "target" => 2,
              }
            ]
          },
          "players" => %{
            "1" => %{
              "actions" => %{
                "1" => %{
                  "vote" => %{
                    "type" => "vote",
                    "target" => 2,
                    "option" => "none",
                    "result" => "villager"
                  }
                }
              },
              "alive" => true,
              "host" => true,
              "id" => 1,
              "role" => "none"
            }
          }
        },
        "rules" => %{"state" => "initialized"}
      }
    ]
  end

  defp state(_context) do
    [
      state: %{
        game: %Werewolf.Game{
          end_phase_unix_time: nil,
          id: 178,
          phase_length: :day,
          phases: 0,
          win_status: :werewolf_win,
          targets: %{
            1 => [
              %Werewolf.KillTarget{
                type: :werewolf,
                target: 2,
              }
            ]
          },
          players: %{
            1 => %Werewolf.Player{
              actions: %{
                1 => %{
                  vote: %Werewolf.Action{
                    type: :vote,
                    target: 2,
                    result: :villager
                  }
                }
              },
              alive: true,
              host: true,
              id: 1,
              role: :none
            }
          }
        },
        rules: %Werewolf.Rules{state: :initialized}
      }
    ]
  end
end
