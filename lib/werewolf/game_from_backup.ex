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
    |> Map.put(:phase_length, String.to_atom(game.phase_length))
  end

  defp convert_players_from_map(players_as_map) do
    Enum.reduce(players_as_map, %{}, fn ({key, value}, accumulator) ->
      Map.put(accumulator, String.to_integer(key), convert_player_from_map(value))
    end)
  end

  defp convert_player_from_map(player_as_map) do
    player = struct(Werewolf.Player, map_keys_to_atoms(player_as_map))
    Map.put(player, :role, String.to_atom(player.role))
    |> Map.put(:actions, convert_actions_from_map(player.actions))
  end

  defp convert_actions_from_map(actions_as_map) do
    Enum.reduce(actions_as_map, %{}, fn ({key, value}, accumulator) ->
      Map.put(accumulator, String.to_integer(key), convert_action_from_map(value))
    end)
  end

  defp convert_action_from_map(action_as_map) do
    action = struct(Werewolf.Action, map_keys_to_atoms(action_as_map))
    Map.put(action, :type, String.to_atom(action.type))
  end

  defp convert_rules_from_map(nil), do: nil
  defp convert_rules_from_map(rules_as_map) do
    rules = struct(Werewolf.Rules, map_keys_to_atoms(rules_as_map))
    Map.put(rules, :state, String.to_atom(rules.state))
  end

  defp map_keys_to_atoms(nil), do: nil
  defp map_keys_to_atoms(map) do
    for {key, val} <- map, into: %{}, do: {String.to_atom(key), val}
  end

  defp map_keys_to_integers(map) do
    for {key, val} <- map, into: %{}, do: {String.to_integer(key), val}
  end
end
