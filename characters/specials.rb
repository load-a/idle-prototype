# frozen_string_literal: true

# Contains all of the Special Moves (traits)
# These methods the Round or other objects directly and return a string for the Log

module Specials
  module_function

  SPEED_KEY = {
    "2" => 3.5,
    "4" => 3,
    "6" => 2.5,
    "8" => 2,
    "10" => 1.5,
    "12" => 1, 
    "20" => 0.5
  }.freeze


  def none(_source, _type, _round)
    "...but nothing happened."
  end

  def followup(source, type, round)
    modifier = Dice.roll(source.power).result
    round[type] += modifier
    "#{source.name} followed up the #{type} for +#{modifier}"
  end

  def powerup(source, type, round)
    round[type] += source.power
    "#{source.name} powered up for +#{source.power} #{type}"
  end

  def opportunity(source, type, round)
    modifier = Dice.roll(source.max_focus).result
    round[type] += modifier
    "#{source.name} saw an opportunity and took it for +#{modifier} to #{type}"
  end

  def punishment(source, type, round)
    round[type] += source.max_focus
    "#{source.name} saw a mistake and punished it for +#{source.max_focus} to #{type}"
  end

  def quick_step(source, type, round)
    multiplier = SPEED_KEY[source.speed.to_s]
    boost = (source.power * multiplier).round
    round[type] += boost
    "#{source.name} got +#{boost} to #{type} using their quick footwork"
  end

  def side_step(source, type, round)
    multiplier = SPEED_KEY[source.speed.to_s]

    return "... but #{source.name} is too slow to use Side Step" if multiplier <= 1

    round[type] = (round[type] * multiplier).round
    "#{source.name} stepped to the side and multiplied their #{type} by #{multiplier}"
  end

  def berserk(source, _type, round)
    damage = (source.health / 2).floor

    return "#{source.name} tried to go berserk but couldn't" if damage.zero?

    target = opposing_team(source, round).sample

    source.take_damage(damage)
    target.take_damage(damage)

    "#{source.name} went berserk!\n   #{source.name} and #{target.name} both took #{damage} damage"
  end

  def snipe(source, _type, round)
    target = opposing_team(source, round).sample

    target.take_damage(source.power)

    "#{source.name} quickly sniped #{target.name} for #{source.power} damage"
  end

  def crossfire(source, _type, round)
    target = opposing_team(source, round).sample

    target.take_damage(Dice.roll(source.power).result)

    "#{target.name} took #{source.power} damage in the commotion"
  end

  def heal_self(source, _type, _round)
    mending = Dice.roll(source.power).result
    source.recover(mending)
    "#{source.name} healed +#{mending} HP"
  end

  def heal_ally(source, _type, round)
    ally = source_team(source, round).sample

    mending = Dice.roll(source.power).result
    ally.recover(mending)

    "#{source.name} healed #{ally.name} for +#{mending} health"
  end

  def heal_team(source, _type, round)
    mending = Dice.roll(source.power).result

    source_team(source, round).each { |teammate| teammate.recover(mending) }

    "#{source.name}'s whole squad restored #{mending} health"
  end

  def focus_self(source, _type, _round)
    charge = Dice.roll(source.power).result
    source.charge_focus(charge)
    "#{source.name} locked in for +#{charge} focus"
  end

  def focus_ally(source, _type, round)
    ally = source_team(source, round).sample

    charge = Dice.roll(source.power).result
    ally.charge_focus(charge)

    "#{ally.name} got inspired for +#{charge} focus"
  end

  def focus_team(source, _type, round)
    charge = Dice.roll(source.power).result

    source_team(source, round).each { |teammate| teammate.charge_focus(charge) }

    "#{source.name}'s whole squad gained #{charge} focus"
  end

  def backup(source, type, round)
    return "#{source.name} called for backup... but no one could come" if source_team(source, round).length <= 1

    backup = allies(source, round)
    ally = backup.sample
    assist = Dice.roll(ally.power).result

    round[type] += assist

    "#{source.name} called for backup. #{ally.name} helped out with +#{assist} #{type}"
  end

  def gang_up(source, type, round)
    return "#{source.name} called for the squad... but they're not around" if allies(source, round).empty?

    backup = allies(source, round)
    assist = 0

    backup.each do |ally|
      assist += Dice.roll(ally.power).result
    end

    round[type] += assist

    "#{source.name}'s whole squad came out to help with +#{assist} #{type}"
  end

  def mastery(source, type, round)
    full_power = (source.power + source.max_focus) * SPEED_KEY[source.speed.to_s]
    round[type] += full_power.round
    "#{source.name}'s eyes are glowing..."
  end

  def source_team(source, round)
    team_type = round[:attack_team].include?(source) ? :attack_team : :defense_team
    round[team_type].members
  end

  def allies(source, round)
    team_type = round[:attack_team].include?(source) ? :attack_team : :defense_team
    team = round[team_type]
    team.members.select { |teammate| teammate != source }
  end

  def opposing_team(source, round)
    team_type = round[:attack_team].include?(source) ? :defense_team : :attack_team
    round[team_type].members
  end
end
