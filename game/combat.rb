# frozen_string_literal: true

class Round
  attr_accessor :attacker, :defender, :results, :round, :turn

  def initialize(attacker, defender)
    self.attacker = attacker
    self.defender = defender
    self.results = {
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

  def roll_encounter
    roll_attack
    roll_counter
    roll_defense
    set_low_health_traits
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

  def set_low_health_traits
    results[:breaker] = attacker.low_health?
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

class Match

  attr_accessor :player, :cpu, :round, :encounter, :log

  def initialize(player, cpu)
    self.player = player
    self.cpu = cpu
    self.round = 0
    self.encounter = nil
    self.log = []
  end

  def play
    teams = [player, cpu].shuffle

    loop do
      self.round += 1

      teams.reverse!

      direction = teams.first == player ? '>>>' : '<<<'

      log << "Round #{round}".center(101)
      log << bracket(direction)
      log << "\n"

      # Run all combat
      teams[0].each do |member|
        play_round(member, teams[1].sample)
        member.charge_focus
      end

      teams.each do |team|
        team.reject! {|teammate| teammate.down? }
      end

      if teams.any?(&:empty?)

        if (teams[0] & cpu).none?
          log << "you win"
        else
          log << "you lose"
        end

        break
      end
    end
  end

  def bracket(direction = '...')
    right = cpu.map(&:brief)
    left = player.map {|opponent| opponent.brief(true)}
    sign = []

    [right, left].map(&:length).max.times do |number|
      sign << '%48s %s %-48s' % [left[number], direction, right[number]]
    end

    sign
  end

  def alert(message, front_symbol = '!! ', back_symbol = nil)
    back_symbol = front_symbol.reverse if back_symbol.nil?

    '%s%s%s' % [front_symbol, message, back_symbol]
  end

  # @todo extract these into their own methods
  def play_round(attacker, defender)
    round = Round.new(attacker, defender)

    bullet = ->(amount) { if amount.positive? then '-- ' elsif amount.zero? then '~~ ' else '++ ' end }

    # Attack Roll
    if round[:crit_attack]
      log << "Critical attack!"
    end
    log << "#{attacker.name} attacked #{defender.name} for #{round[:attack]} damage"

    # Counter Damage Taken
    if round[:counter] > 0
      attacker.health -= round[:counter]
      log << "#{defender.name} got some hits in"
      log << alert("#{attacker.name} took #{round[:counter]} counter damage", bullet.call(round[:counter]))
    end

    # Defense Roll
    if round[:crit_defense]
      log << "Critical defense!"
    end
    log << "#{defender.name} blocked for #{round[:defense]} defense"

    # Damage Taken
    damage = [round[:attack] - round[:defense], 0].max
    defender.health -= damage
    log << alert("#{defender.name} took #{damage} damage", bullet.call(damage))

    # Breaker
    if attacker.charged?
      log << "#{attacker.name} uses BREAKER" 
      attacker.reset_focus
    end

    # Clutch
    log << "#{defender.name} uses CLUTCH" if defender.low_health?

    # Defeats
    if attacker.down?
      log << alert("#{attacker.name} is down")
    end

    if defender.down?
      log << alert("#{defender.name} is down")
    end

    log << "\n"
  end
end

module Combat
  module_function

  def start(home_team, away_team)
    game = Match.new(home_team, away_team)

    game.play

    game.log
  end
end
