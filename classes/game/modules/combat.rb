# frozen_string_literal: true

module GameCombat
  def show_combat_log
    Output.new_screen(combat_log)
    Input.ask_keypress
  end

  def start_match
    encounter = run_combat
    earnings = earn_money(encounter)
    self.combat_log = encounter.log

    combat_log << earnings
    notify earnings

    teammate_application
  end

  def earn_money(encounter)
    rounds = encounter.round_number
    challenge = encounter.cpu_team.challenge_rating(player.team)
    challenge *= 2 if challenge.negative?
    time_bonus = 1 + ([rounds - 10, 0].max / 30.0) # No bonus for finishing in 10 or fewer rounds
    survival_bonus = rounds / 30.0 
    earnings = ((player.team.might + challenge) * time_bonus).round

    if encounter.winner == :draw
      earnings /= 2
      player.money += earnings
      format "Earnings: $#{earnings}"
    elsif encounter.winner == :cpu
      earnings = (challenge * survival_bonus).round
      player.money += earnings
      format "Earnings: Risk(%s) * Survival(%.2f) = $%i", challenge, survival_bonus, earnings
    else
      player.money += earnings
      format "Winnings: Strength(%s) + Risk(%s) * Time(%.2f) = $%i", player.team.might, challenge, time_bonus, earnings
    end
  end

  def run_combat
    allied_team = player.team
    opposing_team = next_opponent

    match_header = [
      hud,
      "#{allied_team.name} vs. #{opposing_team.name}".center(120),
      allied_team.to_s,
      '',
      opposing_team.to_s,
      ''
    ]

    encounter = CombatEncounter.new(allied_team, opposing_team)
    encounter.log.prepend(match_header)
    encounter
  end
end
