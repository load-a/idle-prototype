# frozen_string_literal: true

module Special
  module_function

  def beast(context, type)
    character = type == :attack ? "attacker" : "defender"

    puts "#{context.send(character).name} went BEAST MODE for +#{context.encounter.send(type).result} #{type}!"

    context.encounter.send(type).result *= 2
  end

  def counter(context, _type)

  end

  def dodge(context, _type)
    context.encounter.defense.result = context.encounter.attack.result
    puts "#{context.defender.name} dodged!"
  end

  def lock_in(context, _type)
    return unless context.encounter.attack.result >= context.defender.health

    chance = Dice.roll(2)

    return puts "#{context.defender.name} couldn't lock in fast enough! (#{chance})" unless chance.crit

    context.encounter.defense.result = context.encounter.attack.result - context.defender.health + 1
    puts "#{context.defender.name} locked in!"
  end

  def multi_hit(context, _type)
    disadvantage = [(context.defender.power - context.attacker.power), 2].max
    hits = rand(1..disadvantage)
    total = 0

    hits.times do
      total += Dice.roll(context.attacker.power).result
    end

    context.encounter.attack.result += total

    puts "#{context.attacker.name} gets #{hits} more hits in for +#{total} damage!"
  end

  def psychic(context, type)
    character = context.send(type == :attack ? "attacker" : "defender")
    roll = Dice.roll(character.focus).result

    context.encounter.send(type).result += roll

    puts "#{character.name} used psychic power for +#{roll} #{type}!"
  end

  def none(_encounter, _type); end
end
