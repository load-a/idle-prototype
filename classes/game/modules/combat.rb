# frozen_string_literal: true

module GameCombat
  def show_combat_log
    system 'clear'
    puts combat_log

    Input.ask_keypress
  end

  def run_combat
    allied_team = player.team
    opposing_team = next_opponent

    match_header = [
      calendar.date,
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
