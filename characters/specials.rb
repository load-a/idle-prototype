# frozen_string_literal: true

# Contains all of the Special Moves (traits)
# These methods the Round or other objects directly and return a string for the Log

module Specials
  module_function

  def none(_source, _type, _round)
    "...but nothing happened."
  end

  def roll_power(source, type, round)
    modifier = Dice.roll(source.power).result
    round[type] += modifier
    "#{source.name} added +#{modifier} to #{type}"
  end

  def powerup(source, type, round)
    round[type] += source.power
    "#{source.name} added +#{source.power} to #{type}"
  end

  def roll_focus(source, type, round)
    modifier = Dice.roll(source.max_focus).result
    round[type] += modifier
    "#{source.name} added +#{modifier} to #{type}"
  end

  def add_focus(source, type, round)
    round[type] += source.max_focus
    "#{source.name} added +#{source.max_focus} to #{type}"
  end

  def quick_step(source, type, round)
    modifier = Dice.roll(source.speed).result
    round[type] += modifier
    "#{source.name} added +#{modifier} to #{type}"
  end

  def side_step(source, type, round)
    round[type] += source.speed
    "#{source.name} added +#{source.speed} to #{type}"
  end

  def berserk(source, _type, round)
    damage = source.health / 2

    return "#{source.name} tried to go berserk but couldn't" if damage.zero?

    target_team = round[:attack_team].include?(source) ? :defense_team : :attack_team
    target = round[target_team].sample

    source.take_damage(damage)
    target.take_damage(damage)

    "#{source.name} went berserk and hit #{target.name} for +#{damage} damage"
  end

  def snipe(source, _type, round)
    target_team = round[:attack_team].include?(source) ? :defense_team : :attack_team
    target = round[target_team].sample

    target.take_damage(source.power)

    "#{source.name} sniped #{target.name} for +#{source.power} damage"
  end

  def heal_self(source, _type, _round)
    mending = Dice.roll(source.power).result
    source.recover(mending)
    "#{source.name} recovered +#{mending} health"
  end

  def heal_ally(source, _type, round)
    target_team = round[:attack_team].include?(source) ? :attack_team : :defense_team
    target = round[target_team].sample

    mending = Dice.roll(source.power).result
    target.recover(mending)

    "#{source.name} healed #{target.name} for +#{mending} health"
  end

  def mastery(source, type, round)
    full_power = (source.power + source.speed + source.max_focus)
    round[type] += full_power
    "#{source.name}'s eyes are glowing..."
  end
end
