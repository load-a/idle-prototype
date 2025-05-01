# frozen_string_literal: true

require_relative 'calendar'
require_relative 'player'
require_relative 'house'
require_relative 'shop'
require_relative 'menus/menus'

class Game
  include Menus

  HELP_MENU = ['Command List', '', '[C]hallengers', '[E]xpense Report', 'Combat [L]og','[H]ouse Stats',
  '[I]nventory', '[M]anage Team', '[P]ass the Time', '[T]imetable', '', '[Q]uit']

  attr_accessor :player, :calendar, :log, :next_opponent, :combat_log, :expenses, :house, :inventory

  def initialize
    self.player = Player.new('Player')
    # player.team = TEAMS[0]
    self.calendar = Calendar.new
    self.log = Array.new(16, ' ')
    self.combat_log = []
    self.inventory = {
      abilities: [ABILITIES[:intimidate], ABILITIES[:inspire_team], ABILITIES[:boost_ally], ABILITIES[:berserk]],
      consumables: [],
      upgrades: []
    }

    self.next_opponent = nil
    self.house = House.new

    initialize_expenses

    player.team.members.each { |member| member.set_schedule }
  end

  def notify(text)
    log << text
    log.flatten!
    while log.size > 16
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
      puts Output.columns([["$#{player.money}"], [calendar.date], 
      [format("Today's opponent: %-16s", next_opponent&.leader&.name)]], 
      row_headers: [player.name], left_div: ' ')
      puts player.team
      puts Output.columns([log], row_headers: HELP_MENU, left_div: ' > ')
      response = Input.ask_char('Enter a command:').character

      case response
      when 'c'
        challenge_menu
      when 'e'
        expense_menu
      when 'h'
        puts house.to_s
        Input.ask_char('...')
      when 'i'
        inventory_screen
        Input.ask_char('...')
      when 'l'
        next notify('No combat log') if combat_log.empty? 

        show_combat_log
      when 'm'
        puts player.team
        Input.ask_char('(go [B]ack)')
      when 'p'
        system 'clear'
        show_time_screen
        hours = number_of_hours
        pass_time(hours)
      when 's'
        puts "STORE"
      when 't'
        time_menu
      when 'q'
        exit
      else
        notify "DEBUG: Invalid action: Main Menu > [#{response.upcase}]" if response != '?'
      end
    end
  end

  def show_combat_log
    system 'clear'
    puts combat_log

    Input.ask_char('[B]ack')
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
end
