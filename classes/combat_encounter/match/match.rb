# frozen_string_literal: true

require_relative 'match_methods'
require_relative 'match_output'
require_relative 'round'

class Match
  include MatchOutput
  include MatchMethods

  attr_accessor :player_team, :cpu_team, :round_number, :log, :winner

  def initialize(player_team, cpu_team_team)
    self.player_team = player_team
    self.cpu_team = cpu_team_team
    self.round_number = 0
    self.log = []
    self.winner = nil
  end

  def play
    teams = [player_team, cpu_team].shuffle

    loop do
      self.round_number += 1

      teams.reverse!

      direction = teams.first == player_team ? '>>>' : '<<<'

      log << "Round #{round_number}".center(120)
      log << bracket(direction).map { |line| line.center(120) }
      log << "\n"

      # Run all combat
      teams[0].members.each do |member|
        break if teams[1].members.empty?
        next if member.down?

        play_round(member, teams[1].sample, teams[0], teams[1])
        teams[1].remove_defeated

        if member.up?
          member.charge_focus
          log << "#{member.name} is ready to BREAK" if member.charged?
        end

        log << "\n"
      end

      teams[0].remove_defeated

      next unless teams.any?(&:defeated?)

      if player_team.defeated? && cpu_team.defeated?
        log << 'Draw!'
        winner == :draw
      elsif cpu_team.defeated?
        log << 'you win'
        self.winner = :player
      else
        log << 'you lose'
        self.winner = :cpu
      end

      player_team.restore_defeated
      break
    end

    cpu_team.restore_defeated
    cpu_team.members.each(&:full_heal)
  end

  def play_round(attacker, defender, attacker_team, defender_team)
    round = Round.new(attacker, defender, attacker_team, defender_team)

    # Attack phase
    log << alert("#{attacker.name} vs #{defender.name}", '** ')
    process_critical_attack(attacker, round) if round[:crit_attack]
    log << "#{attacker.name} attacked #{defender.name} for #{round[:attack]} damage"

    # Counter Damage Taken
    apply_counter_damage(attacker, defender, round) if round[:counter].positive?

    # Defense phase
    process_critical_defense(defender, round) if round[:crit_defense]
    log << "#{defender.name} blocked for #{round[:defense]} defense"

    # Breaker
    process_breaker(attacker, round) if attacker.charged?

    # Clutch
    process_clutch(defender, round) if round[:clutch]

    # Damage Taken
    apply_encounter_damage(defender, round)
    log << "#{defender.name} is gonna try to clutch this next one" if defender.low_health? && defender.up?

    # Alert defeated characters
    alert_downs(attacker_team, defender_team)
  end
end
