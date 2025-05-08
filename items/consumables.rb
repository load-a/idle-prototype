# frozen_string_literal: true

module Consumables
  module_function

  def coffee(actor, _action = nil, _round_data = nil)
    actor.recover(10)
    "#{actor.name} drank some coffee and regained 10 Health"
  end

  def energy_drink(actor, _action = nil, _round_data = nil)
    actor.recover(15)
    "#{actor.name} drank some energy_drink and regained 15 Health"
  end

  def water(actor, _action = nil, _round_data = nil)
    actor.recover(20)
    "#{actor.name} drank some water and regained 20 Health"
  end

  def candy(actor, _action = nil, _round_data = nil)
    actor.recover(4)
    "#{actor.name} ate some candy and gained 4 FOCUS"
  end

  def chips(actor, _action = nil, _round_data = nil)
    actor.recover(8)
    "#{actor.name} ate some chips and gained 8 FOCUS"
  end

  def snack_bar(actor, _action = nil, _round_data = nil)
    actor.recover(12)
    "#{actor.name} ate a snack bar and gained 12 FOCUS"
  end
end
