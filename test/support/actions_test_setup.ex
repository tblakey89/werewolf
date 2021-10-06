defmodule Werewolf.Support.ActionsTestSetup do
  alias Werewolf.{Action, Rules, Player, Item}

  def vote_action(_context), do: [vote_action: %Action{type: :vote, target: "target"}]

  def no_kill_vote_action(_context),
    do: [no_kill_vote_action: %Action{type: :vote, target: "no_kill"}]

  def invalid_vote(_context), do: [invalid_vote: %Action{type: :vote, target: "target"}]

  def heal_action(_context), do: [heal_action: %Action{type: :heal, target: "target"}]

  def inspect_action(_context), do: [inspect_action: %Action{type: :inspect, target: "target"}]

  def watch_action(_context), do: [watch_action: %Action{type: :watch, target: "target"}]

  def hunt_action(_context), do: [hunt_action: %Action{type: :hunt, target: "target"}]

  def assassinate_action(_context),
    do: [assassinate_action: %Action{type: :assassinate, target: "target"}]

  def resurrect_action(_context),
    do: [resurrect_action: %Action{type: :resurrect, target: "target"}]

  def poison_action(_context), do: [poison_action: %Action{type: :poison, target: "target"}]

  def steal_action(_context), do: [steal_action: %Action{type: :steal, target: "target"}]

  def sabotage_action(_context), do: [sabotage_action: %Action{type: :sabotage, target: "target"}]

  def curse_action(_context), do: [curse_action: %Action{type: :curse, target: "target"}]

  def transform_action(_context),
    do: [transform_action: %Action{type: :transform, target: "target"}]

  def disentomb_action(_context),
    do: [disentomb_action: %Action{type: :disentomb, target: "target"}]

  def overrule_action(_context), do: [overrule_action: %Action{type: :overrule, target: "target"}]

  def defend_action(_context), do: [defend_action: %Action{type: :defend, target: "target"}]

  def summon_action(_context), do: [summon_action: %Action{type: :summon, target: "target"}]

  def strangle_action(_context), do: [strangle_action: %Action{type: :strangle, target: "target"}]

  def bite_action(_context), do: [bite_action: %Action{type: :bite, target: "target"}]

  def player(_context), do: [player: %Player{host: false, alive: true, id: "test"}]

  def dead_player(_context), do: [dead_player: %Player{host: false, alive: false, id: "test"}]

  def werewolf(_context),
    do: [
      werewolf: %Player{host: false, alive: true, id: "test", role: :werewolf, team: :werewolf}
    ]

  def dead_werewolf(_context),
    do: [
      dead_werewolf: %Player{
        host: false,
        alive: false,
        id: "test",
        role: :werewolf,
        team: :werewolf
      }
    ]

  def doctor(_context),
    do: [
      doctor: %Player{
        host: false,
        alive: true,
        id: "test",
        role: :doctor,
        items: [Item.new(:first_aid_kit)]
      }
    ]

  def dead_doctor(_context),
    do: [
      dead_doctor: %Player{
        host: false,
        alive: false,
        id: "test",
        role: :doctor,
        items: [Item.new(:first_aid_kit)]
      }
    ]

  def detective(_context),
    do: [
      detective: %Player{
        host: false,
        alive: true,
        id: "test",
        role: :detective,
        items: [Item.new(:magnifying_glass)]
      }
    ]

  def dead_detective(_context),
    do: [
      dead_detective: %Player{
        host: false,
        alive: false,
        id: "test",
        role: :detective,
        items: [Item.new(:magnifying_glass)]
      }
    ]

  def devil(_context),
    do: [
      devil: %Player{
        host: false,
        alive: true,
        id: "test",
        role: :devil,
        items: [Item.new(:magnifying_glass)]
      }
    ]

  def dead_devil(_context),
    do: [
      dead_devil: %Player{
        host: false,
        alive: false,
        id: "test",
        role: :devil,
        items: [Item.new(:magnifying_glass)]
      }
    ]

  def little_girl(_context),
    do: [
      little_girl: %Player{
        host: false,
        alive: true,
        id: "test",
        role: :little_girl,
        items: [Item.new(:binoculars)]
      }
    ]

  def dead_little_girl(_context),
    do: [
      dead_little_girl: %Player{
        host: false,
        alive: false,
        id: "test",
        role: :little_girl,
        items: [Item.new(:binoculars)]
      }
    ]

  def hunter(_context),
    do: [
      hunter: %Player{
        host: false,
        alive: true,
        id: "test",
        role: :hunter,
        items: [Item.new(:dead_man_switch)]
      }
    ]

  def dead_hunter(_context),
    do: [
      dead_hunter: %Player{
        host: false,
        alive: false,
        id: "test",
        role: :hunter,
        items: [Item.new(:dead_man_switch)]
      }
    ]

  def witch(_context),
    do: [
      witch: %Player{
        host: false,
        alive: true,
        id: "test",
        role: :witch,
        items: [Item.new(:resurrection_scroll), Item.new(:poison)]
      }
    ]

  def dead_witch(_context),
    do: [
      dead_witch: %Player{
        host: false,
        alive: false,
        id: "test",
        role: :witch,
        items: [Item.new(:resurrection_scroll)]
      }
    ]

  def ninja(_context),
    do: [
      ninja: %Player{
        host: false,
        alive: true,
        id: "test",
        role: :ninja,
        items: [Item.new(:sword)]
      }
    ]

  def dead_ninja(_context),
    do: [
      dead_ninja: %Player{
        host: false,
        alive: false,
        id: "test",
        role: :ninja,
        items: [Item.new(:sword)]
      }
    ]

  def werewolf_thief(_context),
    do: [
      werewolf_thief: %Player{
        host: false,
        alive: true,
        id: "test",
        role: :werewolf_thief,
        team: :werewolf,
        items: [Item.new(:lock_pick)]
      }
    ]

  def dead_werewolf_thief(_context),
    do: [
      dead_werewolf_thief: %Player{
        host: false,
        alive: false,
        id: "test",
        role: :werewolf_thief,
        team: :werewolf,
        items: [Item.new(:lock_pick)]
      }
    ]

  def werewolf_detective(_context),
    do: [
      werewolf_detective: %Player{
        host: false,
        alive: true,
        id: "test",
        role: :werewolf_detective,
        items: [Item.new(:magnifying_glass)]
      }
    ]

  def dead_werewolf_detective(_context),
    do: [
      dead_werewolf_detective: %Player{
        host: false,
        alive: false,
        id: "test",
        role: :werewolf_detective,
        items: [Item.new(:magnifying_glass)]
      }
    ]

  def werewolf_saboteur(_context),
    do: [
      werewolf_saboteur: %Player{
        host: false,
        alive: true,
        id: "test",
        role: :werewolf_saboteur,
        items: [Item.new(:hammer)]
      }
    ]

  def dead_werewolf_saboteur(_context),
    do: [
      dead_werewolf_saboteur: %Player{
        host: false,
        alive: false,
        id: "test",
        role: :werewolf_saboteur,
        items: [Item.new(:hammer)]
      }
    ]

  def werewolf_collector(_context),
    do: [
      werewolf_collector: %Player{
        host: false,
        alive: true,
        id: "test",
        role: :werewolf_collector,
        items: [Item.new(:cursed_relic)]
      }
    ]

  def dead_werewolf_collector(_context),
    do: [
      dead_werewolf_collector: %Player{
        host: false,
        alive: false,
        id: "test",
        role: :werewolf_collector,
        items: [Item.new(:cursed_relic)]
      }
    ]

  def werewolf_mage(_context),
    do: [
      werewolf_mage: %Player{
        host: false,
        alive: true,
        id: "test",
        role: :werewolf_mage,
        items: [Item.new(:transformation_scroll)]
      }
    ]

  def dead_werewolf_mage(_context),
    do: [
      dead_werewolf_mage: %Player{
        host: false,
        alive: false,
        id: "test",
        role: :werewolf_mage,
        items: [Item.new(:transformation_scroll)]
      }
    ]

  def gravedigger(_context),
    do: [
      gravedigger: %Player{
        host: false,
        alive: true,
        id: "test",
        role: :gravedigger,
        items: [Item.new(:pick)]
      }
    ]

  def dead_gravedigger(_context),
    do: [
      dead_gravedigger: %Player{
        host: false,
        alive: false,
        id: "test",
        role: :gravedigger,
        items: [Item.new(:pick)]
      }
    ]

  def judge(_context),
    do: [
      judge: %Player{
        host: false,
        alive: true,
        id: "test",
        role: :judge,
        items: [Item.new(:scales_of_justice)]
      }
    ]

  def dead_judge(_context),
    do: [
      dead_judge: %Player{
        host: false,
        alive: false,
        id: "test",
        role: :judge,
        items: [Item.new(:scales_of_justice)]
      }
    ]

  def lawyer(_context),
    do: [
      lawyer: %Player{
        host: false,
        alive: true,
        id: "test",
        role: :lawyer,
        items: [Item.new(:defence_case)]
      }
    ]

  def dead_lawyer(_context),
    do: [
      dead_lawyer: %Player{
        host: false,
        alive: false,
        id: "test",
        role: :lawyer,
        items: [Item.new(:defence_case)]
      }
    ]

  def summoner(_context),
    do: [
      summoner: %Player{
        host: false,
        alive: true,
        id: "test",
        role: :summoner,
        items: [Item.new(:summoning_scroll)]
      }
    ]

  def dead_summoner(_context),
    do: [
      dead_summoner: %Player{
        host: false,
        alive: false,
        id: "test",
        role: :summoner,
        items: [Item.new(:summoning_scroll)]
      }
    ]

  def serial_killer(_context),
    do: [
      serial_killer: %Player{
        host: false,
        alive: true,
        id: "test",
        role: :serial_killer,
        team: :serial_killer,
        items: []
      }
    ]

  def dead_serial_killer(_context),
    do: [
      dead_serial_killer: %Player{
        host: false,
        alive: false,
        id: "test",
        role: :serial_killer,
        team: :serial_killer,
        items: []
      }
    ]

  def werewolf_alpha(_context),
    do: [
      werewolf_alpha: %Player{
        host: false,
        alive: true,
        id: "test",
        role: :werewolf_alpha,
        items: [Item.new(:lycans_tooth)]
      }
    ]

  def dead_werewolf_alpha(_context),
    do: [
      dead_werewolf_alpha: %Player{
        host: false,
        alive: false,
        id: "test",
        role: :werewolf_alpha,
        items: [Item.new(:lycans_tooth)]
      }
    ]

  def day_state(_context), do: [day_state: %Rules{state: :day_phase}]

  def night_state(_context), do: [night_state: %Rules{state: :night_phase}]

  def players(_context),
    do: [players: %{"target" => %Player{id: "target", host: false, alive: true}}]

  def dead_players(_context),
    do: [dead_players: %{"target" => %Player{id: "target", host: false, alive: false}}]

  def ghost_players(_context),
    do: [
      ghost_players: %{"target" => %Player{id: "target", host: false, alive: false, role: :ghost}}
    ]
end
