# frozen_string_literal: true

module Dice
  module_function

  DiceRoll = Struct.new(:result, :crit)

  def roll(sides)
    rand(1..sides)
  end

  def roll_low(sides, on_crit: nil)
    result = roll(sides)
    crit = result == 1

    return DiceRoll.new(result, crit) unless crit && on_crit

    result = roll(sides) if on_crit == :reroll
    result += roll(sides) if on_crit == :add

    DiceRoll.new(result, crit)
  end

  def roll_high(sides, on_crit: nil)
    result = roll(sides)
    crit = result == sides

    return DiceRoll.new(result, crit) unless crit && on_crit

    result = roll(sides) if on_crit == :reroll
    result += roll(sides) if on_crit == :add

    DiceRoll.new(result, crit)
  end
end
