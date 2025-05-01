# frozen_string_literal: true

class Item
  attr_accessor :name, :description, :type, :cost

  def initialize(name, description, type, cost)
    self.name = name
    self.description = description
    self.type = type
    self.cost = cost
  end

  def inventory_line
    "#{name} - #{description}"
  end

  def store_line
    format("%s")
  end
end

class Shop
  attr_accessor :items

  def generate; end
end
