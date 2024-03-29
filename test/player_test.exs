defmodule Werewolf.PlayerTest do
  use ExUnit.Case
  import Werewolf.Support.PlayerTestSetup
  alias Werewolf.{Player, Action, Item, KillTarget, Options}

  describe "new/2" do
    setup [:user]

    test "returns Player struct set to host when host", context do
      {:ok, player} = Player.new(:host, context[:user])
      assert player == %Player{id: context[:user].id, host: true}
    end

    test "returns Player struct set not to host when normal player", context do
      {:ok, player} = Player.new(:player, context[:user])
      assert player == %Player{id: context[:user].id, host: false}
    end
  end

  describe "match_team?/2" do
    setup [:player_map]

    test "returns true when on same team", context do
      assert true ==
               Player.match_team?(
                 context[:player_map]["villager"],
                 context[:player_map]["detective"]
               )
    end

    test "returns false when on different team", context do
      assert false ==
               Player.match_team?(
                 context[:player_map]["villager"],
                 context[:player_map]["werewolf"]
               )
    end
  end

  describe "update_items/2" do
    setup [:player_map]

    test "changes items for player", context do
      player =
        Player.update_items(context[:player_map]["villager"], [Item.new(:magnifying_glass)])

      assert length(player.items) == 1
    end
  end

  describe "assign_roles/1" do
    test "when 5 players" do
      assigned_players = Map.values(Player.assign_roles(generate_players(5), []))
      assert Enum.count(assigned_players, fn player -> player.role == :werewolf end) == 1
      assert Enum.count(assigned_players, fn player -> player.role == :villager end) == 4
    end

    test "when 8 players" do
      assigned_players = Map.values(Player.assign_roles(generate_players(8), []))
      assert Enum.count(assigned_players, fn player -> player.role == :werewolf end) == 2
      assert Enum.count(assigned_players, fn player -> player.role == :villager end) == 6
      assert Enum.count(assigned_players, fn player -> player.role == :detective end) == 0
      assert Enum.count(assigned_players, fn player -> player.role == :doctor end) == 0
    end

    test "when 2 players, doctor, detective included" do
      assigned_players =
        Map.values(Player.assign_roles(generate_players(2), [:doctor, :detective]))

      assert Enum.count(assigned_players, fn player -> player.role == :werewolf end) == 1
      assert Enum.count(assigned_players, fn player -> player.role == :villager end) == 0

      assert Enum.count(assigned_players, fn player ->
               player.role == :detective || player.role == :doctor
             end) == 1
    end

    test "when 8 players, doctor, detective included" do
      assigned_players =
        Map.values(Player.assign_roles(generate_players(8), [:doctor, :detective]))

      assert Enum.count(assigned_players, fn player -> player.role == :werewolf end) == 2
      assert Enum.count(assigned_players, fn player -> player.role == :villager end) == 4
      assert Enum.count(assigned_players, fn player -> player.role == :detective end) == 1
      assert Enum.count(assigned_players, fn player -> player.role == :doctor end) == 1
    end

    test "when 8 players, mason included" do
      assigned_players = Map.values(Player.assign_roles(generate_players(8), [:mason]))

      assert Enum.count(assigned_players, fn player -> player.role == :werewolf end) == 2
      assert Enum.count(assigned_players, fn player -> player.role == :villager end) == 4
      assert Enum.count(assigned_players, fn player -> player.role == :mason end) == 2
    end

    test "when 18 players, 4 werewolves, 14 villagers" do
      assigned_players =
        Map.values(Player.assign_roles(generate_players(18), [:doctor, :detective]))

      assert Enum.count(assigned_players, fn player -> player.role == :werewolf end) == 4
      assert Enum.count(assigned_players, fn player -> player.role == :villager end) == 12
      assert Enum.count(assigned_players, fn player -> player.role == :detective end) == 1
      assert Enum.count(assigned_players, fn player -> player.role == :doctor end) == 1
    end

    test "when 18 players, 4 werewolves, all additional roles" do
      assigned_players =
        Map.values(
          Player.assign_roles(generate_players(18), [
            :doctor,
            :detective,
            :mason,
            :little_girl,
            :devil,
            :hunter,
            :fool,
            :witch,
            :medium,
            :ninja,
            :werewolf_thief,
            :werewolf_detective,
            :werewolf_saboteur,
            :werewolf_collector,
            :gravedigger,
            :judge,
            :lawyer
          ])
        )

      assert Enum.count(assigned_players, fn player -> player.role == :werewolf end) == 0
      assert Enum.count(assigned_players, fn player -> player.role == :villager end) == 0
      assert Enum.count(assigned_players, fn player -> player.role == :detective end) == 1
      assert Enum.count(assigned_players, fn player -> player.role == :doctor end) == 1
      assert Enum.count(assigned_players, fn player -> player.role == :mason end) == 2
      assert Enum.count(assigned_players, fn player -> player.role == :little_girl end) == 1
      assert Enum.count(assigned_players, fn player -> player.role == :devil end) == 1
      assert Enum.count(assigned_players, fn player -> player.role == :hunter end) == 1
      assert Enum.count(assigned_players, fn player -> player.role == :fool end) == 1
      assert Enum.count(assigned_players, fn player -> player.role == :witch end) == 1
      assert Enum.count(assigned_players, fn player -> player.role == :medium end) == 1
      assert Enum.count(assigned_players, fn player -> player.role == :ninja end) == 1
      assert Enum.count(assigned_players, fn player -> player.role == :gravedigger end) == 1
      assert Enum.count(assigned_players, fn player -> player.role == :judge end) == 1
      assert Enum.count(assigned_players, fn player -> player.role == :lawyer end) == 1
      assert Enum.count(assigned_players, fn player -> player.role == :werewolf_thief end) == 1

      assert Enum.count(assigned_players, fn player -> player.role == :werewolf_detective end) ==
               1

      assert Enum.count(assigned_players, fn player -> player.role == :werewolf_saboteur end) == 1

      assert Enum.count(assigned_players, fn player -> player.role == :werewolf_collector end) ==
               1

      assert Enum.find(assigned_players, fn player -> player.role == :detective end).items == [
               Item.new(:magnifying_glass)
             ]

      assert Enum.find(assigned_players, fn player -> player.role == :doctor end).items == [
               Item.new(:first_aid_kit)
             ]

      assert Enum.find(assigned_players, fn player -> player.role == :mason end).items == [
               Item.new(:phone)
             ]

      assert Enum.find(assigned_players, fn player -> player.role == :little_girl end).items == [
               Item.new(:binoculars)
             ]

      assert Enum.find(assigned_players, fn player -> player.role == :devil end).items == [
               Item.new(:magnifying_glass)
             ]

      assert Enum.find(assigned_players, fn player -> player.role == :hunter end).items == [
               Item.new(:dead_man_switch)
             ]

      assert Enum.find(assigned_players, fn player -> player.role == :fool end).items == []

      assert Enum.find(assigned_players, fn player -> player.role == :witch end).items == [
               Item.new(:poison),
               Item.new(:resurrection_scroll)
             ]

      assert Enum.find(assigned_players, fn player -> player.role == :medium end).items == [
               Item.new(:crystal_ball)
             ]

      assert Enum.find(assigned_players, fn player -> player.role == :ninja end).items == [
               Item.new(:sword)
             ]

      assert Enum.find(assigned_players, fn player -> player.role == :werewolf_thief end).items ==
               [
                 Item.new(:lock_pick)
               ]

      assert Enum.find(assigned_players, fn player -> player.role == :werewolf_detective end).items ==
               [
                 Item.new(:magnifying_glass)
               ]

      assert Enum.find(assigned_players, fn player -> player.role == :werewolf_saboteur end).items ==
               [
                 Item.new(:hammer)
               ]

      assert Enum.find(assigned_players, fn player -> player.role == :werewolf_collector end).items ==
               [
                 Item.new(:cursed_relic)
               ]

      assert Enum.find(assigned_players, fn player -> player.role == :gravedigger end).items ==
               [
                 Item.new(:pick)
               ]

      assert Enum.find(assigned_players, fn player -> player.role == :judge end).items ==
               [
                 Item.new(:scales_of_justice)
               ]

      assert Enum.find(assigned_players, fn player -> player.role == :lawyer end).items ==
               [
                 Item.new(:defence_case)
               ]
    end

    test "when 18 players, additional roles" do
      assigned_players =
        Map.values(
          Player.assign_roles(generate_players(18), [
            :werewolf_mage,
            :summoner,
            :serial_killer,
            :werewolf_alpha,
            :guard,
            :werewolf_thug
          ])
        )

      assert Enum.count(assigned_players, fn player -> player.role == :werewolf end) == 1
      assert Enum.count(assigned_players, fn player -> player.role == :villager end) == 11
      assert Enum.count(assigned_players, fn player -> player.role == :werewolf_mage end) == 1
      assert Enum.count(assigned_players, fn player -> player.role == :werewolf_alpha end) == 1
      assert Enum.count(assigned_players, fn player -> player.role == :summoner end) == 1
      assert Enum.count(assigned_players, fn player -> player.role == :serial_killer end) == 1
      assert Enum.count(assigned_players, fn player -> player.role == :guard end) == 1
      assert Enum.count(assigned_players, fn player -> player.role == :werewolf_thug end) == 1
      assert Enum.find(assigned_players, fn player -> player.role == :villager end).items == []
      assert Enum.find(assigned_players, fn player -> player.role == :werewolf end).items == []

      assert Enum.find(assigned_players, fn player -> player.role == :werewolf_mage end).items ==
               [
                 Item.new(:transformation_scroll)
               ]

      assert Enum.find(assigned_players, fn player -> player.role == :summoner end).items ==
               [
                 Item.new(:summoning_scroll)
               ]

      assert Enum.find(assigned_players, fn player -> player.role == :serial_killer end).items ==
               []

      assert Enum.find(assigned_players, fn player -> player.role == :werewolf_alpha end).items ==
               [
                 Item.new(:lycans_tooth)
               ]

      assert Enum.find(assigned_players, fn player -> player.role == :guard end).items ==
               [
                 Item.new(:lock)
               ]

      assert Enum.find(assigned_players, fn player -> player.role == :werewolf_thug end).items ==
               [
                 Item.new(:bat)
               ]
    end
  end

  describe "add_status/2" do
    setup [:regular_player]

    test "when status already present", context do
      player = context[:regular_player]
      player = put_in(player.statuses, [:silenced])
      {:ok, player} = Player.add_status(player, :imprisoned)
      assert player.statuses == [:imprisoned, :silenced]
    end

    test "when no statuses", context do
      player = context[:regular_player]
      {:ok, player} = Player.add_status(player, :imprisoned)
      assert player.statuses == [:imprisoned]
    end
  end

  describe "blocking_status?/1" do
    setup [:regular_player]

    test "when is imprisoned", context do
      player = context[:regular_player]
      player = put_in(player.statuses, [:imprisoned])
      assert Player.blocking_status?(player)
    end

    test "when is not imprisoned", context do
      player = context[:regular_player]
      assert !Player.blocking_status?(player)
    end
  end

  describe "clear_player_statuses/2" do
    setup [:regular_player]

    test "when status already present", context do
      player = context[:regular_player]
      player = put_in(player.statuses, [:silenced, :imprisoned])
      {:ok, player} = Player.clear_player_statuses(player, [:silenced])
      assert player.statuses == [:imprisoned]
    end

    test "when no statuses", context do
      player = context[:regular_player]
      {:ok, player} = Player.clear_player_statuses(player, [:silenced, :imprisoned])
      assert player.statuses == []
    end
  end

  describe "clear_players_statuses/2" do
    setup [:player_map]

    test "when status already present", context do
      players = context[:player_map]
      players = put_in(players["villager"].statuses, [:silenced])
      {:ok, players} = Player.clear_players_statuses(players, [:silenced])
      assert Enum.all?(players, fn {id, player} -> player.statuses == [] end)
    end
  end

  describe "remove_phase_statuses/1" do
    test "when night phase" do
      assert Player.remove_phase_statuses(1) == [:imprisoned]
    end

    test "when day phase" do
      assert Player.remove_phase_statuses(2) == [:silenced]
    end
  end

  describe "add_action/4" do
    setup [:regular_player]

    test "when phase number key does not exist", context do
      new_action = %Action{type: :vote, target: "user"}
      {:ok, player} = Player.add_action(context[:regular_player], "1", new_action, %Options{})
      assert player.actions["1"][:vote] == new_action
    end

    test "when phase number key exists, but action type does not", context do
      player = context[:regular_player]
      player = put_in(player.actions["1"], %{})
      new_action = %Action{type: :vote, target: "user"}
      {:ok, player} = Player.add_action(player, "1", new_action, %Options{})
      assert player.actions["1"][:vote] == new_action
    end

    test "when phase number key exists, but action type does not, action change not allowed",
         context do
      player = context[:regular_player]
      player = put_in(player.actions["1"], %{})
      new_action = %Action{type: :vote, target: "user"}

      {:ok, player} =
        Player.add_action(player, "1", new_action, %Options{allow_action_changes: false})

      assert player.actions["1"][:vote] == new_action
    end

    test "when phase number key exists, and action type exists", context do
      player = context[:regular_player]
      player = put_in(player.actions["1"], %{vote: %{}})
      new_action = %Action{type: :vote, target: "user"}
      assert player.actions["1"][:vote] == %{}
      {:ok, player} = Player.add_action(player, "1", new_action, %Options{})
      assert player.actions["1"][:vote] == new_action
    end

    test "when phase number key exists, and action type exists, action change not allowed",
         context do
      player = context[:regular_player]
      player = put_in(player.actions["1"], %{vote: %{}})
      new_action = %Action{type: :vote, target: "user"}
      assert player.actions["1"][:vote] == %{}

      {:error, error} =
        Player.add_action(player, "1", new_action, %Options{allow_action_changes: false})

      assert error == :allow_action_changes_not_enabled
    end
  end

  describe "remove_action/3" do
    setup [:regular_player]

    test "when phase number key does not exist", context do
      new_action = %Action{type: :vote, target: "user"}

      assert {:ok, context[:regular_player]} ==
               Player.remove_action(context[:regular_player], "1", :vote)
    end

    test "when phase number key exists, but action type does not", context do
      player = context[:regular_player]
      player = put_in(player.actions["1"], %{})
      {:ok, player} = Player.remove_action(player, "1", :vote)
      assert player.actions["1"] == %{}
    end

    test "when phase number key exists, and action type exists", context do
      player = context[:regular_player]
      action = %Action{type: :vote, target: "user"}
      {:ok, player} = Player.add_action(player, "1", action, %Options{})
      {:ok, player} = Player.remove_action(context[:regular_player], "1", :vote)
      assert player.actions["1"][:vote] == nil
    end
  end

  describe "claim_role/2" do
    setup [:regular_player, :dead_player]

    test "when player dead", context do
      {:error, reason} = Player.claim_role(context[:dead_player], "detective")
      assert reason == :dead
    end

    test "when regular player claims role", context do
      {:ok, player} = Player.claim_role(context[:regular_player], "detective")
      assert player.claim == "detective"
    end
  end

  describe "use_items/2" do
    setup [:additional_player_map]

    test "when using item owned by user", context do
      players = context[:additional_player_map]
      {:ok, player} = Player.add_action(players["witch"], 1, Action.new(:resurrect, "villager"))
      players = put_in(players["witch"], player)
      {:ok, players} = Player.use_items(players, 1)
      assert Enum.at(players["witch"].items, 0).remaining_uses == 0
    end

    test "when using item not owned by user", context do
      players = context[:additional_player_map]
      {:ok, player} = Player.add_action(players["witch"], 1, Action.new(:heal, "villager"))
      players = put_in(players["witch"], player)
      {:ok, players} = Player.use_items(players, 1)
      assert Enum.at(players["witch"].items, 0).remaining_uses == 1
    end
  end

  describe "relevant_player?/3" do
    setup [:regular_player_map, :dead_player_map, :player_map, :additional_player_map]

    test "returns true for dead player when given dead", context do
      assert Player.relevant_player?(:day_phase, context[:dead_player_map][3], :dead) == true
    end

    test "returns false for alive player when given dead", context do
      assert Player.relevant_player?(:day_phase, context[:regular_player_map][2], :dead) == false
    end

    test "returns true for alive player when given dead, but has crystal_ball", context do
      assert Player.relevant_player?(:day_phase, context[:additional_player_map]["medium"], :dead) ==
               true
    end

    test "returns true for player when matches role", context do
      assert Player.relevant_player?(:day_phase, context[:additional_player_map]["mason"], :mason) ==
               true
    end

    test "returns true for player when matches team", context do
      assert Player.relevant_player?(
               :day_phase,
               context[:additional_player_map]["werewolf_thief"],
               :werewolf
             ) ==
               true
    end

    test "returns true for player when lover", context do
      players = context[:additional_player_map]
      players = put_in(players["mason"].lover, true)
      assert Player.relevant_player?(:day_phase, players["mason"], :lover) == true
    end

    test "returns false for player when not lover", context do
      assert Player.relevant_player?(:day_phase, context[:additional_player_map]["mason"], :lover) ==
               false
    end

    test "returns false for player when matches role but dead", context do
      player = %{
        context[:player_map]["werewolf"]
        | alive: false
      }

      assert Player.relevant_player?(:day_phase, player, :werewolf) == false
    end

    test "returns false for player that does not match role", context do
      assert Player.relevant_player?(:day_phase, context[:player_map]["villager"], :werewolf) ==
               false
    end

    test "returns true for ghost player when given dead in day phase", context do
      assert Player.relevant_player?(:day_phase, context[:additional_player_map]["ghost"], :dead) ==
               true
    end

    test "returns false for ghost player when given dead in day phase", context do
      assert Player.relevant_player?(
               :night_phase,
               context[:additional_player_map]["ghost"],
               :dead
             ) == false
    end
  end

  describe "alignment/2" do
    setup [:additional_player_map]

    test "when player is team village", context do
      players = context[:additional_player_map]
      assert :order == Player.alignment(players["witch"])
    end

    test "when player is team werewolf", context do
      players = context[:additional_player_map]
      assert :chaos == Player.alignment(players["werewolf_thief"])
    end

    test "when player is team fool", context do
      players = context[:additional_player_map]
      assert :chaos == Player.alignment(players["fool"])
    end
  end

  defp generate_players(player_number) do
    Enum.reduce(
      for(n <- 1..player_number, do: %Player{id: "test#{n}", host: false}),
      %{},
      fn player, acc ->
        put_in(acc[player.id], player)
      end
    )
  end
end
