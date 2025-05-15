# frozen_string_literal: true

class Inventory
  attr_accessor :abilities, :consumables, :upgrades, :subscriptions

  def initialize
    self.abilities = []
    self.consumables = []
    self.upgrades = []
    self.subscriptions = []
  end

  def to_h
    item_hash.merge({ subscriptions: subscriptions })
  end

  def item_hash
    {
      abilities: abilities,
      consumables: consumables,
      upgrades: upgrades
    }
  end

  def show_items
    header = Output.columns(%w[Abilities Consumables Upgrades], content_just: :center, left_edge: '|', right_div: '|')
    divider = header.join.gsub(/\w|\s/, '-')

    puts header, divider
    puts Output.columns(item_hash.values.map { |list| list.map(&:inventory_line) }, left_edge: '|', right_div: '|')
    puts divider.gsub('-', '_')
  end

  def take(item)
    send(item.type) << item
  end

  def remove(category_id, item_index)
    send(category_id).delete_at(item_index)
  end
  alias give remove

  def list(category_id, display: false)
    listing = send(category_id)
    listing.each_with_index { |item, index| puts format('%i. %s', index + 1, item.name) } if display
    listing
  end

  def serialize
    to_h.transform_values do |category|
      category.map(&:id)
    end
  end

  def deserialize(serial_hash)
    serial_hash.each do |category, items|
      send("#{category}=", items.map { |item_id| Object.const_get(category.upcase).fetch(item_id.to_sym) })
      send(category).compact!
    end

    self
  end
end
