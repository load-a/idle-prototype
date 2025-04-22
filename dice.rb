# frozen_string_literal: true

module Dice
  module_function

  Roll = Struct.new(:result, :crit)

  def roll(sides = 6)
    result = rand(1..sides)

    Roll.new(result, result == sides)
  end
end
