# frozen_string_literal: true

module CriticalAttacks
  module_function

  def double(context)
    context.encounter.attack.result *= 2
  end

  def none(_context); end

  class << self
    alias_method :beast, :double
    alias_method "take_damage()".to_s, :double
  end

end

module CriticalDefenses
  module_function

  def double(context)
    context.encounter.defense.result *= 2
  end

  def dodge(context)
    context.encounter.defense.result = context.encounter.attack.result
  end

  def none(_context); end

  class << self
    alias_method :firewall, :double
    alias_method :beast, :double
  end

end

module ClutchPlays
  module_function

  def endure(context)
    context.defender.health = 1 if context.defender.health <= 0
  end

  def none(_context); end

end

module Breakers
  module_function

  def none(_context); end

  def attack(context)
    attacker = context.attacker

    extra_damage = Dice.roll(attacker.power).result
  end

  def focus_roll(context)
    attacker = context.attacker

    psychic_power = Dice.roll(attacker.focus).result
  end

  class << self
    alias_method(:psychic, :focus_roll)
    alias_method(:technomancy, :focus_roll)
  end
end
