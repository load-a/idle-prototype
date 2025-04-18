# frozen_string_literal: true

require_relative 'calendar'
require_relative 'off_time'
require_relative 'input'
require_relative 'output'

class Game
  include Input
  include Output

  attr_accessor :calendar, :player, :team, :next_opponent, :shop, :log, :money

  def initialize
    self.calendar = Calendar.new
    self.player = CHARACTERS[:alyssa]
    self.team = Team.new([player, CHARACTERS[:yumi], CHARACTERS[:tomoe], CHARACTERS[:xia]], "Player's Team",  'Your team.')
    self.next_opponent = nil
    self.shop = []
    self.log = []
    self.money = 100

    team.members.each { |character| OffTime.set_schedule(character) }
  end

  def initialize_player
    letter = ''

    loop do 
      letter = ask('Please enter your favorite letter').upcase
      
      break if letter =~ /[A-Z]/
    end
    
    character = CHARACTERS.select {|id, character| character.name.start_with?(letter)}.values[0]

    self.player = character

    puts "you picked #{player}"

    OffTime.set_schedule(player)
  end

  def pass_time
    hours = ask_number('How many hours?', 2).clamp(0, 24)

    return if hours.zero?

    say "Passing #{hours} hours." if hours > 1

    day = calendar.day

    hours.times do
      say "-- #{calendar.hour} o' Clock --"

      team.each do |teammate|
       teammate.pass_time(calendar.hour)

       task = teammate.schedule[calendar.hour]

       text = case task
              when :sleep
                ['slept.', "copped some Z's.", 'had a nice dream.', 'had a weird dream'].sample
              when :out
                ['was busy elsewhere.', 'ran some errands.'].sample
              when :train
                ['focused on training.', 'prayed at the iron church.', 'got swole.', 'practiced a bit.'].sample
              when :rest
                ['got some R&R.', 'took a nap', 'hydrated.', 'had a snack', 'hung out with some friends.'].sample
              when :job
                ['was at work.', 'made some money.'].sample
              end

       say "- #{teammate.name} #{text}"
     end

      if player.schedule[calendar.hour] == :match
        encounter = Combat.play_match(team, next_opponent)
        say encounter[:log]

        if encounter[:winner] == :player
          reward = encounter[:rounds] * encounter[:cpu].map(&:power).sum
          self.money += reward
          say "Team earned $#{reward} for winning."
        end
      end

      calendar.advance_hour

      if calendar.hour.zero?
        say "\n--- #{calendar.full_date} ---\n" 
        say "$#{team.map(&:cost).sum} spent on daily expenses."

        team.each { |character| OffTime.set_schedule(character) }
        self.next_opponent = nil
        self.money -= team.map(&:cost).sum
      end
    end

    if day != calendar.day
      
    end
  end

  def schedule_match
    return puts "Match already scheduled against #{next_opponent.name}" if next_opponent

    number = rand(2..4)
    opponents = CHARACTERS.values
    opponents.reject! {|character| character == player }
    opponents = opponents.sample(number)

    puts numbered_list(opponents.map(&:status))
    puts 'Pick your opponent: [0] to cancel'

    pick = get_number.clamp(0, opponents.length)

    return if pick == 0
  
    self.next_opponent = opponents[pick - 1]
    puts "You picked #{self.next_opponent.to_s}"

    puts show_schedule
    puts 'Pick a time. (Cannot be OUT or SLEEP)'

    slot = get_number(2).clamp(0, 24)

    return puts "That time has already passed" if calendar.time_has_passed?(slot)

    puts OffTime.schedule_match(player, slot)
  end

  def test_play
    system 'clear'

    main_menu
  end

  def main_menu
    loop do 
      Screen.new.show("#{'_' * (calendar.hour + 1)}", [calendar.date, "$#{money}", 'Enter an action:'])
      action = get_string

      case action
      when 'c'
        # Challenge
        record 'Opened Challenge menu.'
        next say "Challenge already scheduled for today." unless next_opponent.nil?

        opponents = generate_opponents

        puts "Choose an opponent:"
        choice = get_number(1).clamp(0, opponents.length)

        next say "Challenge cancelled." if choice.zero?

        self.next_opponent = opponents[choice - 1]
        say "Challenging #{next_opponent.map(&:name).join(', ')} to a match"

        team_schedules

        schedule_the_match
      when 'e'
        # expenses
        record 'Opened Expense Report.'
        team_expenses = team.map{ |character| [character.name, character.cost] }
        daily_expenses = team.map(&:cost).sum
        team_expenses << ['Total', daily_expenses]

        Screen.new('EXPENSE REPORT', '%20s: $%i').show('', team_expenses)
      when 'h'
        record('Opened Help Menu.')
        help_menu = [
          'C: Challenge another team to a match',
          'E: Team expense chart',
          'H: Help (This menu)', 
          'M: Manage team and view stats',
          'P: Pass time by the hour',
          'Q: Quit game',
          'S: Team schedule viewer'
        ]
        Screen.new.show('Main Actions', help_menu)
      when 'm'
        record 'Opened Management menu.'
        management_menu
      when 'p'
        pass_time
      when 'q'
        record('Quit the game.')
        break
      when 's'
        team_schedules
      else
        say("Action not supported: [#{action.upcase}]")
      end
    end
  end

  def team_schedules
    puts "TEAM SCHEDULES".center(74)
    list =  team.map do |teammate|
              [teammate.name] + teammate.schedule
            end

    columns(16, list).each_with_index do |row, hour|
      pointer = (hour - 1 == calendar.hour ? ' -> ' : '    ')

      next puts "     TIME " + row if hour == 0

      puts '%s%02i:00 %s' % [pointer, hour - 1, row]
    end
  end

  def generate_opponents
    challengers = CHARACTERS.values.dup
    challengers.reject! { |character| team.include? character }.sample(team.length)
    number = rand(2..4)

    opponents = []

    number.times do
      opponents << challengers.sample(team.length)
    end

    opponents.each_with_index do |opposing_team, index|
      multi_stat_screen("#{index + 1}. #{opposing_team[0].name}'s Team", opposing_team)
    end

    opponents
  end

  def schedule_the_match
    loop do
      puts "Pick a time: (enter '24' to cancel)"

      time = get_number(2).clamp(0, 24)

      if time == 24
        say "Challenge cancelled." 
        self.next_opponent = nil
        break 
      end

      if calendar.time_has_passed? time
        puts 'That time has already passed'
      elsif team.none? {|teammate| %i[out sleep job].include? teammate.schedule[time]} 
        say "Match scheduled for #{time} o' clock against #{next_opponent.first.name}'s team."
        team.each {|teammate| teammate.schedule[time] = :match}
        break
      else
        puts "Cannot schedule at #{time} because:"
        team.each do |teammate|
          next unless %i[sleep out job].include? teammate.schedule[time]

          puts "- #{teammate.name} is #{teammate.schedule[time]} at that time."
        end
      end
    end
  end

  def management_menu
    multi_stat_screen("TEAM STATS", team)

    action = ask('Enter an action: ')

    case action
    when 'a'
      pick = ask_number('Pick a teammate', 1).clamp(0, 4)

      return say "Team assignment cancelled." if pick.zero?
      teammate = team[pick - 1]

      loop do
        task = ask "Assign which activity to #{teammate.name}?", 5

        if %w[rest job train free].include? task
          teammate.assignment = task.to_sym
          break
        elsif task == 'b'
          say "Team assignment cancelled." 
          return 
        else
          puts "Enter [rest], [job], [train] or [free] to assign task, or [B] to go back."
        end
      end
    when 'b'
      return
    when 'd'
      pick = ask_number('Pick a teammate to drop.', 1).clamp(0, 4)

      return say "Team deletion cancelled." if pick.zero?
      teammate = team[pick - 1]

      puts "Are you sure you want to drop #{teammate.name}?"
      answer = ask "You will have to earn their respect again to get them back. (y/n)"

      if answer == 'y'
        say "#{teammate.name} was dropped from the team."
        team.delete(teammate)
      else
        puts "delete cancelled"
      end
    when 'h'
      record('Opened Help Menu.')
      help_menu = [
        "A: Set a team member's assignment.",
        'B: Go back to main menu.',
        'D: Drop a member from the team',
        'H: Help (This menu)', 
        'I: Use an item on a teammate',
      ]
      Screen.new.show('Management Actions', help_menu)
    when 'i'
      # use item
    end
  end

  def test_combat
    playing_team = team
    opposing_team = TEAMS[2]

    puts "#{playing_team.name} vs. #{opposing_team.name}".center(120)
    multi_stat_screen(playing_team.name, playing_team)
    puts "~~ #{playing_team.description} ~~".center(120), ''

    multi_stat_screen(opposing_team.name, opposing_team)
    puts "~~ #{opposing_team.description} ~~".center(120), ''

    puts Combat.start(playing_team, opposing_team)
  end
end
