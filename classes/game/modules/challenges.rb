# frozen_string_literal: true

# Handles all the logic for challenge matches and match scheduling
module GameChallenges
  DESCRIPTIONS = [
    'Time to throw hands', 'Here to have fun', 'Pick a god and pray', 'Ready and willing',
    "You're comparing yourself to me? HA! You're not even good enough to be my fake.",
    'Do you think love can blossom on the battlefield?', 'Like, zoinks, Scoob', 'My rhymes are fly. My beats are sick.',
    'Rev up those fryers!', "Don't get cooked!", "It's not about the money. It's about the love of the game!",
    'Time to END THIS'
  ]
  def generate_challengers
    potential_opponents = CHARACTERS.values.reject { |character| player.team.include? character }
    new_challengers = TEAMS.select {|team| team.length == player.team.length}
    quantity = rand(1..4)

    8.times do
      new_team = Team.new(potential_opponents.sample(player.team.size).map { |character| character.dup })
      new_team.description = DESCRIPTIONS.sample

      new_challengers << scale_back(new_team) unless new_challengers.any? { |team| team.same_members? new_team }
      # new_challengers << new_team unless new_challengers.any? { |team| team.same_members? new_team } # for testing
    end

    new_challengers.reject! { |team| team.same_members? player.team }
    self.challengers = new_challengers.sample(quantity)
  end

  def scale_back(team)
    team.members.map!(&:dup)
    risk = team.challenge_rating(player.team)
    return team if risk.negative?

    trait_keys = %i[attack defense clutch breaker]

    team.members.each do |character|
      character.traits[:clutch] = NO_ITEM if risk > 10
      character.traits[:breaker] = NO_ITEM if risk > 20
      character.traits[:defense] = NO_ITEM if risk > 30
      character.traits[:attack] = NO_ITEM if risk > 40
    end

    team
  end

  def show_challengers(challengers)
    Output.new_screen 'Challenger Select', challengers.each(&:to_s)
  end

  def challenge_menu
    return unless can_challenge?

    show_challengers(challengers)

    pick = Input.ask_option(*challengers.map { |team| team.leader.name + " CR: #{team.challenge_rating(player.team)}" }, 
    prompt: 'Pick a challenger:')

    return notify('No challenger selected') if pick.blank?

    challenger = challengers[pick.index]
    puts "Selected #{challenger.name}"
    pick_time(challenger)
  end

  def pick_time(challenger)
    show_time_screen
    time = Input.ask_number('Pick a time')

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
      Output.new_screen(hud, "Today's opponent:".center(SCREEN_WIDTH), next_opponent)
      Input.ask_keypress
      false
    else
      true
    end
  end
end
