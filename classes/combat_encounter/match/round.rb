# frozen_string_literal: true

class Round
  attr_accessor :attacker, :defender, :results, :round, :turn

  def initialize(attacker_formation, defender_formation)
    self.attacker = attacker_formation.actor
    self.defender = defender_formation.actor
    self.results = {
      attack_team: attacker_formation.team,
      defense_team: defender_formation.team,
      attack: 0,
      defense: 0,
      counter: 0,
      crit_attack: false,
      crit_defense: false,
      breaker: false,
      clutch: false
    }

    roll_actions
  end

  def [](key)
    results[key]
  end

  def []=(key, value)
    results[key] = value
  end

  def roll_actions
    roll_attack
    roll_counter
    roll_defense
    set_bonus_traits
  end

  def roll_attack
    attack = Dice.roll_high(attacker.power)
    results[:attack] = attack.result
    results[:crit_attack] = attack.crit
  end

  def roll_defense
    defense = if defender.traits[:defense] == NO_ITEM
                Dice.roll_high(defender.power, on_crit: :add)
              else
                Dice.roll_low(defender.power, on_crit: :reroll)
              end
    results[:defense] = defense.result
    results[:crit_defense] = defense.crit
  end

  def roll_counter
    opportunities = results[:attack] / defender.speed
    opportunities.times do
      results[:counter] += Dice.roll(defender.power)
    end
  end

  def set_bonus_traits
    results[:breaker] = attacker.charged?
    results[:clutch] = defender.low_health?
  end

  def to_s
    log = []

    log << format('%-16s: %s', 'attacker', attacker.name)
    log << format('%-16s: %s', 'defender', defender.name)
    results.each { |label, value| log << format('%-15s: %s', label, value) }
    log << "\n"

    log.join("\n")
  end
end
