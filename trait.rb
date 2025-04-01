# frozen_string_literal: true

class Trait
  attr_accessor :name, :description, :type
  def initialize(name, description, type)
    self.name = name
    self.type = type
    self.description = description
  end

  def attack?
    type & 0b0001 == 1
  end

  def breaker?
    type & 0b0010 == 2
  end

  def clutch?
    type & 0b0100 == 4
  end

  def defense?
    type & 0b1000 == 8
  end

  def to_s
    format('%s: %s [%s]', name, description, type_string)
  end

  def type_string
    types = []

    types << "Attack" if attack?
    types << "Breaker" if breaker?
    types << "Clutch" if clutch?
    types << "Defense" if defense?

    types.join(', ')
  end
end
