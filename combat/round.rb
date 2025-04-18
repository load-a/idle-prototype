# frozen_string_literal: true

class Round
  attr_accessor :attacker, :defender, :results, :round, :turn

  def initialize(attacker, defender, attacker_team, defender_team)
    self.attacker = attacker
    self.defender = defender
    self.results = {
      attack_team: attacker_team,
      defense_team: defender_team,
      attack: 0, 
      defense: 0,
      counter: 0,
      crit_attack: false,
      crit_defense: false,
      breaker: false,
      clutch: false
    }

    roll_encounter
  end

  def [](key)
    self.results[key]
  end

  def []=(key, value)
    self.results[key] = value
  end

  def roll_encounter
    roll_attack
    roll_counter
    roll_defense
    set_bonus_traits
  end

  def roll_attack
    attack = Dice.roll(attacker.power)
    results[:attack] = attack.result
    results[:crit_attack] = attack.crit
  end

  def roll_defense
    defense = Dice.roll(defender.power)
    results[:defense] = defense.result
    results[:crit_defense] = defense.crit
  end

  def roll_counter
    opportunities = results[:attack] / defender.speed
    opportunities.times do
      results[:counter] += Dice.roll(defender.power).result
    end
  end

  def set_bonus_traits
    results[:breaker] = attacker.charged?
    results[:clutch] = defender.low_health?
  end

  def to_s
    log = []

    log << '%-16s: %s' % ['attacker', attacker.name]
    log << '%-16s: %s' % ['defender', defender.name]
    results.each { |label, value| log << '%-15s: %s' % [label, value] }
    log << "\n"

    log.join("\n")
  end
end
