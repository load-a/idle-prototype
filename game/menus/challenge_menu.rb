# frozen_string_literal: true

# Handles all the logic for challenge matches and match scheduling
module ChallengeMenu
  def generate_challengers

    potential_opponents = CHARACTERS.values.reject { |character| player.team.include? character }
    challengers = []

    rand(1..4).times do
      challengers << Team.new(potential_opponents.sample(player.team.size))
    end

    challengers.uniq
  end

  def show_challengers(challengers)
    system 'clear'
    puts 'Challenger Select'
    challengers.each { |team| puts team }
  end

  def challenge_menu
    return unless can_challenge?

    challengers = generate_challengers
    show_challengers(challengers)

    pick = Input.ask_char('Enter pick a team (number)').number - 1

    if (0..challengers.length - 1).include?(pick)
      challenger = challengers[pick]
      puts "Selected #{challenger.name}"
      pick_time(challenger)
    else
      notify 'No challenger selected'
    end
  end

  def pick_time(challenger)
    show_time_screen
    time = Input.ask('Pick a time').number

    unless (0..24).include?(time) && player.team.free?(time) && calendar.hour <= time
      return notify 'Matchmaking cancelled' 
    end

    notify format('Match Scheduled for %02<time>i:00 against %<name>s', { time: time, name: challenger.name })
    self.next_opponent = challenger
    player.team.schedule_match(time)
  end

  def can_challenge?
    if player.team.members.any? { |member| member.health < 20 }
      notify 'The team needs more time to recover'
      false
    elsif next_opponent
      notify 'You already have a match scheduled today'
      false
    else
      true
    end
  end
end
