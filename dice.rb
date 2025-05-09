# frozen_string_literal: true

module Dice
  module_function

  DiceRoll = Struct.new(:result, :crit)

  LEVELS = [2, 4, 6, 8, 10, 12, 20].freeze
  HEALTH_LEVELS = Array.new(9) {|index| (index * 5) + 20}.freeze

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

  def level(level)
    level = (level - 1).clamp(0, 6)
    LEVELS[level]
  end

  def find_level(stat)
    LEVELS.index(stat) + 1
  end

  def inverse_die(die)
    {
      '2' => 20,
      '4' => 12,
      '6' => 10,
      '8' => 8,
      '10' => 6,
      '12' => 4,
      '20' => 2
    }[die.to_s]
  end
end
