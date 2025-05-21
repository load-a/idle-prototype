# frozen_string_literal: true

# Handles all the logic for challenge matches and match scheduling
module GameChallenges
  RISK_THRESHOLD = 20
  GENERATION_LIMIT = 8
  GENERATION_RANGE = (1..4)
  DESCRIPTIONS = [
    'Time to throw hands', 'Here to have fun', 'Pick a god and pray', 'Ready and willing',
    "You're comparing yourself to me? HA! You're not even good enough to be my fake.",
    'Do you think love can blossom on the battlefield?', 'Like, zoinks, Scoob', 'My rhymes are fly. My beats are sick.',
    'Rev up those fryers!', "Don't get cooked!", "It's not about the money. It's about the love of the game!",
    'Time to END THIS'
  ]

  def challenge_menu
    if can_challenge?
      schedule_match
    elsif player.team.members.any?(&:too_weak?)
      notify('Your team needs more time to recover')
    else
      view_next_opponent
      cancel_match if Input.confirm?('Cancel this match?')
    end
  end

  def can_challenge?
    player.team.members.none? { |member| member.too_weak? } && next_opponent.nil?
  end

  def schedule_match
    show_challengers
    challenger = select_challenger
    return notify('No challenger selected') unless challenger

    show_time_screen
    match_time = enter_match_time
    return notify('Cannot schedule at that time') unless match_time

    self.next_opponent = challenger
    player.team.schedule_match(match_time)
    notify format('Match Scheduled for %02<time>i:00 against %<name>s', { time: match_time, name: challenger.name })
  end

  def show_challengers
    Output.new_screen 'Challenger Select', challengers.each(&:to_s)
  end

  def select_challenger
    challenger_options = challengers.map do |team| 
                           '%-16s (Risk: %i)' % [team.leader.name, team.challenge_rating(player.team)]
                         end
    pick = Input.ask_option(challenger_options, prompt: 'Pick a challenger:', joiner: "\n")

    return nil if pick.blank?

    challengers[pick.index]
  end

  def enter_match_time
    time = Input.ask_number('Pick a time')

    return nil unless HOUR_RANGE.include?(time) && player.team.free?(time) && !calendar.past?(time)

    time
  end

  def view_next_opponent
    Output.new_screen(hud, "Today's opponent:".center(SCREEN_WIDTH), next_opponent)
  end

  def cancel_match
    player.team.cancel_match
    self.next_opponent = nil
    notify 'Match cancelled.'
  end

  def generate_challengers
    potential_opponents = CHARACTERS.values.reject { |character| player.team.include? character }
    new_challengers = TEAMS.select {|team| team.length == player.team.length}
    quantity = rand(GENERATION_RANGE)

    GENERATION_LIMIT.times do
      new_team = Team.new(potential_opponents.sample(player.team.size).map { |character| character.dup })
      new_team.description = DESCRIPTIONS.sample

      next if new_challengers.any? { |team| team.same_members? new_team }

      new_challengers << scale_team(new_team) 
      # new_challengers << new_team unless new_challengers.any? { |team| team.same_members? new_team } # for testing
    end

    new_challengers.reject! { |team| team.same_members? player.team }
    self.challengers = new_challengers.sample(quantity)
  end

  def scale_team(team)
    risk = team.challenge_rating(player.team)

    return team if risk < RISK_THRESHOLD

    trait_keys = %i[breaker clutch defense attack]
    team.members.map!(&:dup)

    trait_keys.each do |trait|
      team.members.each { |character| character.traits[trait] = NO_ITEM if risk > RISK_THRESHOLD }
      risk = team.challenge_rating(player.team)
    end

    team
  end
end
