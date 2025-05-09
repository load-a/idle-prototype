# frozen_string_literal: true

require_relative 'calendar'
require_relative 'player'
require_relative 'house'
require_relative 'shop'
require_relative 'menus/menus'

class Game
  include Menus

  MAIN_LOG_SIZE = 16
  HELP_MENU = ['Command List', '', '[C]hallengers', '[E]xpense Report', 'Combat [L]og','[H]ouse Stats',
  '[I]nventory', '[M]anage Team', '[P]ass the Time', '[S]tore', '[T]imetable', '', '[Q]uit']

  attr_accessor :player, :calendar, :log, :next_opponent, :combat_log, :expenses, :house, :inventory, :shop

  def initialize
    self.player = Player.new('Player')
    # player.team = TEAMS[0]
    self.calendar = Calendar.new
    self.log = Array.new(MAIN_LOG_SIZE, ' ')
    self.combat_log = []
    self.inventory = Inventory.new
    inventory.abilities = [ABILITIES[:intimidate], ABILITIES[:inspire_team], ABILITIES[:boost_ally], ABILITIES[:berserk]]
    inventory.upgrades = [UPGRADES[:one_up], UPGRADES[:one_down]]

    self.next_opponent = nil
    self.house = House.new
    self.shop = Shop.new
    shop.generate

    initialize_expenses

    player.team.members.each { |member| member.set_schedule }
  end

  def notify(text)
    log << text
    log.flatten!
    while log.size > MAIN_LOG_SIZE
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
        house.subscriptions = inventory[:subscriptions]
        puts house.to_s
        Input.ask_char('...')
      when 'i'
        inventory_screen
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
        show_shop_menu
      when 't'
        time_menu
      when 'q'
        exit
      else
        notify "DEBUG: Invalid action: Main Menu > [#{response.upcase}]" if response != '?'
      end
    end
  end

  def show_shop_menu
    loop do
      system 'clear'
      shop.show_selection

      category = Input.ask_option('abilities', 'consumables', 'upgrades', 'subscriptions', prompt: 'Choose a category')

      break if category.default?

      purchase = purchase_item(category)

      next if purchase.nil?
    end
  end

  def purchase_item(category)
    system 'clear'
    items = shop.show_category(category.text, player.money) 
    selection = Input.ask_option(*items.map(&:name), prompt: 'select an item')

    return nil if selection.default?

    purchase = items[selection.index]

    return nil if purchase.cost > player.money

    if Input.confirm?("Purchase #{purchase.name} for $#{purchase.cost}?")
      log << "Purchased #{purchase.name} (-$#{purchase.cost})"
      inventory.send(purchase.type) << purchase
      items.delete_at(selection.index)
    else
      log << 'Cancelled purchase'
    end

    purchase
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
