# frozen_string_literal: true

require_relative 'modules/modules'

class Game
  include GameModules

  HELP_MENU = ['Command List', '', '[C]hallengers', '[E]xpense Report', 'Combat [L]og','[H]ouse Stats',
  '[I]nventory', '[M]anage Team', '[P]ass the Time', '[S]tore', '[T]imetable', '', '[Q]uit']

  attr_accessor :player, :calendar, :log, :next_opponent, :combat_log, :expenses, :house, :inventory, :shop

  def initialize(player, calendar, inventory, house, shop)
    self.player = player
    self.calendar = calendar
    self.inventory = inventory
    self.house = house
    self.shop = shop

    initialize_log
    initialize_data

    devevlopment_setup
  end

  def initialize_data
    shop.generate
    initialize_expenses
    player.team.members.each { |member| member.set_schedule }
  end

  def devevlopment_setup
    # player.team = TEAMS[0]
    inventory.abilities = [ABILITIES[:intimidate], ABILITIES[:inspire_team], ABILITIES[:boost_ally], ABILITIES[:berserk]]
    inventory.upgrades = [UPGRADES[:one_up], UPGRADES[:one_down]]
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
      response = Input.ask_char('Enter a command:')

      case response
      when 'c'
        challenge_menu
      when 'e'
        expense_menu
      when 'h'
        house.subscriptions = inventory[:subscriptions]
        puts house.to_s
        Input.ask_keypress
      when 'i'
        inventory_screen
      when 'l'
        next notify('No combat log') if combat_log.empty? 

        show_combat_log
      when 'm'
        puts player.team
        Input.ask_keypress
      when 'p'
        system 'clear'
        show_time_screen
        hours = number_of_hours
        pass_time(hours)
      when 's'
        show_shop_menu
      when 't'
        time_menu
      when 'q'
        exit
      else
        notify "DEBUG: Invalid action: Main Menu > [#{response}]" if response != '?'
      end
    end
  end
end
