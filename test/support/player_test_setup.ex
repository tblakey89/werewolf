defmodule Werewolf.Support.PlayerTestSetup do
  alias Werewolf.Player
  alias Werewolf.Action
  alias Werewolf.Item

  def user(_context), do: [user: %{username: "tester", id: 1}]
  def alt_user(_context), do: [alt_user: %{username: "tester2", id: 2}]

  def host_player_map(_context), do: [host_player_map: %{1 => %Player{id: 1, host: true}}]
  def regular_player_map(_context), do: [regular_player_map: %{2 => %Player{id: 2, host: false}}]

  def dead_player_map(_context),
    do: [dead_player_map: %{3 => %Player{id: 3, host: false, alive: false}}]

  def player_map(_context),
    do: [
      player_map: %{
        "villager" => %Player{id: "villager", host: false, actions: %{}, role: :villager},
        "werewolf" => %Player{id: "werewolf", host: false, actions: %{}, role: :werewolf},
        "doctor" => %Player{
          id: "doctor",
          host: false,
          actions: %{},
          role: :doctor,
          items: [Item.new(:first_aid_kit)]
        },
        "detective" => %Player{
          id: "detective",
          host: false,
          actions: %{},
          role: :detective,
          items: [Item.new(:magnifying_glass)]
        }
      }
    ]

  def additional_player_map(_context),
    do: [
      additional_player_map: %{
        "villager" => %Player{id: "villager", host: false, actions: %{}, role: :villager},
        "werewolf" => %Player{id: "werewolf", host: false, actions: %{}, role: :werewolf},
        "doctor" => %Player{
          id: "doctor",
          host: false,
          actions: %{},
          role: :doctor,
          items: [Item.new(:first_aid_kit)]
        },
        "detective" => %Player{
          id: "detective",
          host: false,
          actions: %{},
          role: :detective,
          items: [Item.new(:magnifying_glass)]
        },
        "little_girl" => %Player{
          id: "little_girl",
          host: false,
          actions: %{},
          role: :little_girl,
          items: [Item.new(:binoculars)]
        },
        "devil" => %Player{
          id: "devil",
          host: false,
          actions: %{},
          role: :devil,
          items: [Item.new(:magnifying_glass)]
        },
        "hunter" => %Player{
          id: "hunter",
          host: false,
          actions: %{},
          role: :hunter,
          items: [Item.new(:dead_man_switch)]
        },
        "hunter_action" => %Player{
          id: "hunter_action",
          host: false,
          actions: %{1 => %{hunt: %Action{type: :hunt, target: "detective"}}},
          role: :hunter,
          items: [Item.new(:dead_man_switch)]
        },
        "fool" => %Player{id: "fool", host: false, actions: %{}, role: :fool},
        "witch" => %Player{
          id: "witch",
          host: false,
          actions: %{},
          role: :witch,
          items: [Item.new(:resurrection_scroll), Item.new(:poison)]
        },
        "medium" => %Player{
          id: "medium",
          host: false,
          actions: %{},
          role: :medium,
          items: [Item.new(:crystal_ball)]
        },
        "ninja" => %Player{
          id: "ninja",
          host: false,
          actions: %{},
          role: :ninja,
          items: [Item.new(:sword)]
        },
        "werewolf_thief" => %Player{
          id: "werewolf_thief",
          host: false,
          actions: %{},
          role: :werewolf_thief,
          items: [Item.new(:lock_pick)]
        },
        "werewolf_detective" => %Player{
          id: "werewolf_detective",
          host: false,
          actions: %{},
          role: :werewolf_detective,
          items: [Item.new(:magnifying_glass)]
        },
        "werewolf_saboteur" => %Player{
          id: "werewolf_saboteur",
          host: false,
          actions: %{},
          role: :werewolf_saboteur,
          items: [Item.new(:hammer)]
        },
        "werewolf_collector" => %Player{
          id: "werewolf_collector",
          host: false,
          actions: %{},
          role: :werewolf_collector,
          items: [Item.new(:cursed_relic)]
        },
        "werewolf_mage" => %Player{
          id: "werewolf_mage",
          host: false,
          actions: %{},
          role: :werewolf_mage,
          items: [Item.new(:transformation_scroll)]
        },
        "gravedigger" => %Player{
          id: "gravedigger",
          host: false,
          actions: %{},
          role: :gravedigger,
          items: [Item.new(:pick)]
        }
      }
    ]

  def regular_player(_context),
    do: [
      regular_player: %Player{
        id: "tester2",
        host: false,
        items: [%Item{type: :flower, remaining_uses: 1}]
      }
    ]

  def players(_context), do: [players: %{"test" => %Player{id: "test", host: false}}]
end
