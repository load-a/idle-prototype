# frozen_string_literal: true

module Criticals
  module_function

  def none(_context); end

end

module ClutchPlays
  module_function

  def none(_context); end

end

module Breakers
  module_function

  def none(_context); end

  def psychic(context)
    attacker = context.attacker

    psychic_power = Dice.roll(attacker.focus).result
  end
end
