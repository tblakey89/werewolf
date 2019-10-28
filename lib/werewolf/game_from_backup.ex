defmodule Werewolf.GameFromBackup do
  def convert(nil), do: nil

  def convert(state_as_map) do
    %{
      game: convert_game_from_map(state_as_map["game"]),
      rules: convert_rules_from_map(state_as_map["rules"])
    }
  end

  defp convert_game_from_map(nil), do: nil

  defp convert_game_from_map(game_as_map) do
    game = struct(Werewolf.Game, map_keys_to_atoms(game_as_map))

    Map.put(game, :players, convert_players_from_map(game.players))
    |> Map.put(:targets, convert_phase_kill_targets_from_map(game.targets))
    |> Map.put(:win_status, string_to_atom(game.win_status))
    |> Map.put(:phase_length, string_to_atom(game.phase_length))
  end

  defp convert_players_from_map(players_as_map) do
    Enum.reduce(players_as_map, %{}, fn {key, value}, accumulator ->
      Map.put(accumulator, String.to_integer(key), convert_player_from_map(value))
    end)
  end

  defp convert_player_from_map(player_as_map) do
    player = struct(Werewolf.Player, map_keys_to_atoms(player_as_map))

    Map.put(player, :role, string_to_atom(player.role))
    |> Map.put(:actions, convert_phase_actions_from_map(player.actions))
  end

  defp convert_phase_kill_targets_from_map(phase_kill_targets_as_map) do
    Enum.reduce(phase_kill_targets_as_map, %{}, fn {key, value}, accumulator ->
      Map.put(accumulator, String.to_integer(key), convert_kill_targets_from_list(value))
    end)
  end

  defp convert_kill_targets_from_list(kill_targets_as_list) do
    Enum.map(kill_targets_as_list, fn kill_target_as_map ->
      kill_target = struct(Werewolf.KillTarget, map_keys_to_atoms(kill_target_as_map))

      Map.put(kill_target, :type, string_to_atom(kill_target.type))
    end)
  end

  defp convert_phase_actions_from_map(phase_actions_as_map) do
    Enum.reduce(phase_actions_as_map, %{}, fn {key, value}, accumulator ->
      Map.put(accumulator, String.to_integer(key), convert_actions_from_map(value))
    end)
  end

  defp convert_actions_from_map(actions_as_map) do
    Enum.reduce(actions_as_map, %{}, fn {key, value}, accumulator ->
      Map.put(accumulator, string_to_atom(key), convert_action_from_map(value))
    end)
  end

  defp convert_action_from_map(action_as_map) do
    action = struct(Werewolf.Action, map_keys_to_atoms(action_as_map))

    Map.put(action, :type, string_to_atom(action.type))
    |> Map.put(:option, string_to_atom(action.option))
    |> Map.put(:result, string_to_atom(action.result))
  end

  defp convert_rules_from_map(nil), do: nil

  defp convert_rules_from_map(rules_as_map) do
    rules = struct(Werewolf.Rules, map_keys_to_atoms(rules_as_map))
    Map.put(rules, :state, string_to_atom(rules.state))
  end

  defp map_keys_to_atoms(nil), do: nil

  defp map_keys_to_atoms(map) do
    for {key, val} <- map, into: %{}, do: {string_to_atom(key), val}
  end

  defp map_keys_to_integers(map) do
    for {key, val} <- map, into: %{}, do: {String.to_integer(key), val}
  end

  defp string_to_atom(nil), do: nil

  defp string_to_atom(string) when is_atom(string), do: string

  defp string_to_atom(string) do
    String.to_atom(string)
  end
end
