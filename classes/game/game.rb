# frozen_string_literal: true

require_relative 'modules/modules'

class Game
  include GameModules

  HELP_MENU = ['Command List', '', '[C]hallengers', '[E]xpense Report', 'Combat [L]og', '[H]ouse Stats',
               '[I]nventory', '[M]anage Team', '[O]ptions' + '[P]ass the Time', '[S]tore', '[T]imetable', '', '[Q]uit']

  attr_accessor :player, :calendar, :log, :next_opponent, :combat_log, :expenses, :house, :inventory, :shop,
                :challengers

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
    generate_challengers
    initialize_expenses
    player.team.members.each { |member| member.set_schedule }
  end

  def devevlopment_setup
    # player.team = TEAMS[0]
    # player.team.members.each { |member| member.set_schedule }

    # inventory.abilities += [ABILITIES[:intimidate], ABILITIES[:inspire_team], ABILITIES[:boost_ally], ABILITIES[:berserk]]
    # inventory.upgrades += [UPGRADES[:one_up], UPGRADES[:one_down]]

    # On Startup ONLY
    inventory.abilities += case player.character.proficiency
                           when :speed
                             [ABILITIES[:side_step]]
                           when :focus
                             [ABILITIES[:opportunity]]
                           when :power
                             [ABILITIES[:followup]]
                           end
  end

  def test_play
    puts calendar.date
    puts player.team

    main_menu
  end

  def main_menu
    loop do
      game_stats = Output.columns([["$#{player.money}"], [calendar.date],
                                   [format("Today's opponent: %-16s", next_opponent&.leader&.name)]],
                                  row_headers: [player.name], left_div: ' ')
      team_view = player.team
      game_log = Output.columns([log], row_headers: HELP_MENU, left_div: ' > ')

      Output.new_screen(game_stats, team_view, game_log)

      response = Input.ask_char('Enter a command:')

      case response
      when 'c'
        challenge_menu
      when 'e'
        expense_menu
      when 'h'
        house.subscriptions = inventory.subscriptions
        puts '', house
        Input.ask_keypress
      when 'i'
        inventory_screen
      when 'l'
        next notify('No combat log') if combat_log.empty?

        show_combat_log
      when 'm'
        puts player.team
        action = Input.ask_option(*%w[Description Remove])
        case action.index
        when 0
          player.team.description = Input.ask('Enter a new team description (max 100 characters)').clean[..100]
        when 1
          remove_teammate
        end
      when 'o'
        Output.new_screen 'Options'
        action = Input.ask_option(*%w[save load erase], prompt: 'Select an option:')
        case action.index
        when 0
          SaveSystem.save(self)
        when 1
          SaveSystem.load(self)
        else
          notify 'not implemented'
        end
      when 'p'
        Output.new_screen
        show_time_screen
        hours = number_of_hours
        pass_time(hours)
      when 's'
        show_shop_menu
      when 't'
        time_menu
      when 'q'
        # puts 'Saving Data'
        # SaveSystem.save(self)
        exit
      else
        notify "DEBUG: Invalid action: Main Menu > [#{response}]" if response != '?'
      end
    end
  end

  def serialize
    {
      player: player.serialize,
      date: calendar.serialize_date,
      hour: calendar.hour,
      combat_log: combat_log,
      inventory: inventory.serialize
    }
  end

  def deserialize(data)
    self.player = player.deserialize(data['player'])

    player.team.members[1..].each do |member|
      expenses << Expense.new("#{member.name}", 'Daily living expenses', 40, :daily, calendar.tomorrow)
    end

    calendar.deserialize(data['date'])
    calendar.hour = data['hour']
    self.combat_log = data['combat_log']
    self.inventory = inventory.deserialize(data['inventory'])
  end
end
