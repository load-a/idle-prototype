# frozen_string_literal: true

class Match
  include CombatOutput
  include CombatMethods

  attr_accessor :player_team, :cpu_team, :round_number, :log

  def initialize(player_team, cpu_team_team)
    self.player_team = player_team
    self.cpu_team = cpu_team_team
    self.round_number = 0
    self.log = []
  end

  def play
    teams = [player_team, cpu_team].shuffle

    loop do
      self.round_number += 1

      teams.reverse!

      direction = teams.first == player_team ? '>>>' : '<<<'

      log << "Round #{round_number}".center(120)
      log << bracket(direction).map {|line| line.center(120)}
      log << "\n"

      # Run all combat
      teams[0].members.each do |member|
        play_round(member, teams[1].sample, teams[0], teams[1])
        member.charge_focus if member.up?
        log << "#{member.name} is ready to BREAK" if member.charged? 
        log << "\n"
      end

      # Remove defeated characters
      teams.each do |team|
        team.members.reject! {|teammate| teammate.down? }
      end

      if teams.any?(&:empty?)

        if (teams[0] & cpu_team).none?
          log << "you win"
        else
          log << "you lose"
        end

        break
      end
    end
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
    log << "#{defender.name} is gonna try to clutch this" if defender.low_health? && defender.up?

    # Alert defeated characters
    check_defeats([player_team, cpu_team])
  end
end

