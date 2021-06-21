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
    |> Map.put(:win_status, convert_string(game.win_status))
    |> Map.put(:phase_length, convert_string(game.phase_length))
    |> Map.put(
      :allowed_roles,
      Enum.map(game.allowed_roles, fn role ->
        convert_string(role)
      end)
    )
    |> Map.put(:options, convert_options_from_map(game.options))
  end

  defp convert_players_from_map(players_as_map) do
    Enum.reduce(players_as_map, %{}, fn {key, value}, accumulator ->
      Map.put(accumulator, String.to_integer(key), convert_player_from_map(value))
    end)
  end

  defp convert_player_from_map(player_as_map) do
    player = struct(Werewolf.Player, map_keys_to_atoms(player_as_map))

    Map.put(player, :role, convert_string(player.role))
    |> Map.put(:team, convert_string(player.team))
    |> Map.put(:actions, convert_phase_actions_from_map(player.actions))
    |> Map.put(:items, convert_items_from_list(player.items))
  end

  defp convert_options_from_map(options_as_map) do
    Werewolf.Options.new(options_as_map)
  end

  defp convert_phase_kill_targets_from_map(phase_kill_targets_as_map) do
    Enum.reduce(phase_kill_targets_as_map, %{}, fn {key, value}, accumulator ->
      Map.put(accumulator, String.to_integer(key), convert_kill_targets_from_list(value))
    end)
  end

  defp convert_kill_targets_from_list(kill_targets_as_list) do
    Enum.map(kill_targets_as_list, fn kill_target_as_map ->
      kill_target = struct(Werewolf.KillTarget, map_keys_to_atoms(kill_target_as_map))

      Map.put(kill_target, :type, convert_string(kill_target.type))
    end)
  end

  defp convert_phase_actions_from_map(phase_actions_as_map) do
    Enum.reduce(phase_actions_as_map, %{}, fn {key, value}, accumulator ->
      Map.put(accumulator, String.to_integer(key), convert_actions_from_map(value))
    end)
  end

  defp convert_actions_from_map(actions_as_map) do
    Enum.reduce(actions_as_map, %{}, fn {key, value}, accumulator ->
      Map.put(accumulator, convert_string(key), convert_action_from_map(value))
    end)
  end

  defp convert_items_from_list(items_as_list) do
    Enum.map(items_as_list, fn item_as_map ->
      item = struct(Werewolf.Item, map_keys_to_atoms(item_as_map))

      Map.put(item, :type, convert_string(item.type))
      |> Map.put(:remaining_uses, convert_string(item.remaining_uses))
    end)
  end

  defp convert_action_from_map(action_as_map) do
    action = struct(Werewolf.Action, map_keys_to_atoms(action_as_map))

    Map.put(action, :type, convert_string(action.type))
    |> Map.put(:option, convert_string(action.option))
    |> Map.put(:result, convert_string(action.result))
  end

  defp convert_rules_from_map(nil), do: nil

  defp convert_rules_from_map(rules_as_map) do
    rules = struct(Werewolf.Rules, map_keys_to_atoms(rules_as_map))
    Map.put(rules, :state, convert_string(rules.state))
  end

  defp map_keys_to_atoms(nil), do: nil

  defp map_keys_to_atoms(map) do
    for {key, val} <- map, into: %{}, do: {convert_string(key), val}
  end

  defp map_keys_to_integers(map) do
    for {key, val} <- map, into: %{}, do: {String.to_integer(key), val}
  end

  defp convert_string(nil), do: nil

  defp convert_string(string) when is_number(string), do: string

  defp convert_string(string) when is_atom(string), do: string

  defp convert_string(string) do
    String.to_atom(string)
  end
end
