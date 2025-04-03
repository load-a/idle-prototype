# frozen_string_literal: true

module CriticalAttacks
  module_function

  def beast(context)
    context.encounter.attack.result *= 2
  end

  def none(_context); end

end

module CriticalDefenses
  module_function

  def dodge(context)
    context.encounter.defense.result = context.encounter.attack.result
  end

  def none(_context); end

end

module ClutchPlays
  module_function

  def none(_context); end

end

module Breakers
  module_function

  def none(_context); end

  def attack(context)
    attacker = context.attacker

    extra_damage = Dice.roll(attacker.power).result
  end

  def psychic(context)
    attacker = context.attacker

    psychic_power = Dice.roll(attacker.focus).result
  end
end
