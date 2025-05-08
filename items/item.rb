require_relative 'abilities'
require_relative 'consumables'

# @todo Design Goals:
#       POWER items should just be a straightforward reroll or modifier
#       FOCUS items should make use of the FOCUS meter (less reliable but potentially stronger than POWER)
#       SPEED items should use the Speed Multiplier to boost the effect of the action
#       

class Item
  attr_accessor :id, :type, :cost, :description

    def initialize(id, type, cost, description)
      self.id = id
      self.type = type
      self.cost = cost
      self.description = description

      raise "Item ID is too long: #{id}" if id.to_s.length > 14
    end

    def name
      id.to_s.split('_').map(&:capitalize).join(' ')
    end

    def short_description
      if description.length >= 22
        description[0...19] + '...'
      else
        description
      end
    end

    def store_line
      format("%-14s $%i\n  %s", name, cost, description)
    end

    def inventory_line
      format("%14s: %-21s", name, short_description)
    end
end

NO_ITEM = Item.new(:none, :none, 0, 'No Item')
