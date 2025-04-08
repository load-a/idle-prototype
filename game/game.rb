# frozen_string_literal: true

require_relative 'calendar'
require_relative 'combat'
require_relative 'off_time'

module Input
  DEFAULT_STRING = '<?>'.freeze

  def get_input(character_limit = 1)
    gets.chomp[0..character_limit - 1]&.downcase || DEFAULT_STRING
  end

  def ask(prompt, character_limit = 1)
    puts prompt
    get_input(character_limit)
  end

  def get_number(digits = 1)
    pick = gets.chomp[0..digits - 1]&.downcase || '0'
    pick.to_i
  end
end

module Output
  SCHEDULE_TEMPLATE = '%s%02i:00 - %s'

  def show_schedule
    times = [
      "#{player.name}'s Schedule for #{calendar.day_of_the_week}, #{calendar.months_of_the_year} #{calendar.day}", 
      "Current Action: #{player.schedule[calendar.hour]}"
    ]

    player.schedule.each_with_index do |activity, hour|
      times << SCHEDULE_TEMPLATE % [(calendar.hour == hour ? '-> ' : '   '), hour, activity]
    end

    times
  end

  def numbered_list(array)
    list = []

    array.each_with_index do |element, index|
      list << '%i. %s' % [index + 1, element]
    end

    list
  end

  # Used for texts shared between the game log and the interface
  def say(text)
    puts text
    log << text
  end

  # Used for the interface only
  def show(screen); end
end

class Game
  include Input
  include Output

  attr_accessor :calendar, :player, :team, :next_opponent, :shop, :log

  def initialize
    self.calendar = Calendar.new
    self.player = nil
    self.team = []
    self.next_opponent = nil
    self.shop = []
    self.log = []

    initialize_player
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

  def play
    loop do 
      get_action
    end
  end

  def get_action
    puts "#{calendar.formal_date}"
    action = ask 'What would you like to do? (set a [M]atch, [P]ass time, [S]ee schedule [Q]uit)'

    case action
    when 'm'
      schedule_match
    when 'p'
      pass_time
    when 'q'
      exit
    when 's'
      puts show_schedule
    else
      puts 'not implemented'
    end
  end

  def pass_time
    hours = ask('How many hours?', 2).to_i
    day = calendar.day

    hours.times do
      OffTime.spend_hour(player)
      puts Combat.play_match([player], [next_opponent])[:log] if player.schedule[calendar.hour] == :match
      calendar.advance_hour
    end

    if day != calendar.day
      OffTime.set_schedule(player)
      self.next_opponent = nil
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
end
