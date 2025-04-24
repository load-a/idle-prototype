# frozen_string_literal: true

require_relative 'calendar'
require_relative 'off_time'
require_relative 'menus/time_menu'
require_relative 'menus/challenge_menu'

class Player
  attr_accessor :name, :character, :team, :money

  def initialize(_name)
    self.name = Response.new('xia').text # Input.ask("what is your name?").text

    character = CHARACTERS.find { |id, _character| id.to_s.start_with?(name[0]) }&.last || CHARACTERS[:alyssa]

    self.character = character #.from_zero
    self.team = Team.new([self.character], "#{name}'s Team", 'Your team')
    self.money = 100
  end
end

class Game
  include TimeMenu
  include ChallengeMenu

  HELP_MENU = ["Command List", '[C]hallenge Screen', '[I]nventory', '[M]anage Team', '[T]imetable', '[Q]uit']

  attr_accessor :player, :calendar, :log, :next_opponent, :combat_log

  def initialize
    self.player = Player.new('Player')
    # player.team = TEAMS[0]
    self.calendar = Calendar.new
    self.log = Array.new(14, ' ')
    self.combat_log = []

    self.next_opponent = nil

    player.team.members.each { |member| member.set_schedule }
  end

  def notify(text)
    log << text
    log.flatten!
    while log.size > 14
      log.shift
    end
  end

  def test_play
    puts calendar.date
    puts player.team

    main_menu
  end

  def main_menu
    loop do
      system 'clear'
      puts Output.columns([["$#{player.money}"], [calendar.date]], row_headers: [player.name], left_div: ' ')
      puts player.team
      puts Output.columns([log.last(14)], row_headers: HELP_MENU, left_div: ' > ')
      response = Input.ask('Pick an action').character

      case response
      when 'c'
        challenge_menu
      when 'i'
        notify 'Inventory not implemented'
      when 'l'
        if combat_log.empty? 
          notify 'No combat log' 
        else
          show_combat_log
        end
      when 'm'
        puts player.team
      when 't'
        time_menu
      when 'q'
        exit
      else
        notify "DEBUG: Invalid action: Main Menu > [#{response.upcase}]"
      end
    end
  end

  def show_combat_log
    system 'clear'
    puts combat_log

    Input.ask('[B]ack')
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

    encounter = Combat.start(allied_team, opposing_team)
    encounter.log.prepend(match_header)
    encounter
  end

  def earn_money(encounter)
    earnings = encounter.cpu_team.all_members.map(&:power).sum * encounter.round_number

    if encounter.winner == :draw
      earnings /= 2
    elsif encounter.winner == :cpu
      earnings *= 0
    end

    player.money += earnings
    "Earned $#{earnings} from the match"
  end

  def test_combat
    allied_team = TEAMS[0]
    opposing_team = TEAMS[1]

    [
      "#{allied_team.name} vs. #{opposing_team.name}".center(120),
      Output.four_stat_screen(allied_team.name, allied_team),
      "~~ #{allied_team.description} ~~".center(120),
      '',
      Output.four_stat_screen(opposing_team.name, opposing_team),
      "~~ #{opposing_team.description} ~~".center(120),
      ''
    ].flatten.each { |line| log << line }

    encounter = Combat.start(allied_team, opposing_team)
    log << encounter.log
  end
end
