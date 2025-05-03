# frozen_string_literal: true

class Shop
  attr_accessor :items

  def initialize(items = {abilities: [], consumables: [], upgrades: [], subscriptions: []})
    self.items = items
  end

  def generate
    self.items = {
      abilities: ABILITIES.values.sample(rand(1..4)),
      consumables: CONSUMABLES.values.sample(rand(1..4)),
      upgrades: UPGRADES.values.sample(rand(1..4)),
      subscriptions: SUBSCRIPTIONS.values.sample(rand(1..4))
    }
  end

  def show_selection
    items.each do |category, selection|
      puts "#{category.capitalize}".fill('.', 120)
      selection.each {|item| puts item.store_line}
    end
  end

  def show_category(category)
    puts category.to_s.capitalize.center(120)
    items[category.to_sym].each { |item| puts item.store_line }
    items[category.to_sym]
  end
end
