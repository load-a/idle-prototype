# frozen_string_literal: true

module PowerAbilities
  def followup(actor, action, round_data)
    modifier = Dice.roll(actor.power)
    round_data[action] += modifier
    "#{actor.name} followed up the #{action} for +#{modifier}"
  end

  def powerup(actor, action, round_data)
    round_data[action] += actor.power
    "#{actor.name} powered up for +#{actor.power} #{action}"
  end

  def heal_self(actor, _action, _round_data)
    mending = Dice.roll(actor.power)
    actor.recover(mending)
    "#{actor.name} healed +#{mending} HP"
  end

  def heal_ally(actor, _action, round_data)
    ally = actor_team(actor, round_data).sample

    mending = Dice.roll(actor.power)
    ally.recover(mending)

    "#{actor.name} healed #{ally.name} for +#{mending} health"
  end

  def heal_team(actor, _action, round_data)
    mending = Dice.roll(actor.power)

    actor_team(actor, round_data).each { |teammate| teammate.recover(mending) }

    "#{actor.name}'s whole squad restored #{mending} health"
  end

  def focus_self(actor, _action, _round_data)
    charge = Dice.roll(actor.power)
    actor.charge_focus(charge)
    "#{actor.name} locked in for +#{charge} focus"
  end

  def focus_ally(actor, _action, round_data)
    ally = actor_team(actor, round_data).sample

    charge = Dice.roll(actor.power)
    ally.charge_focus(charge)

    "#{ally.name} got inspired for +#{charge} focus"
  end

  def focus_team(actor, _action, round_data)
    charge = Dice.roll(actor.power)

    actor_team(actor, round_data).each { |teammate| teammate.charge_focus(charge) }

    "#{actor.name}'s whole squad gained #{charge} focus"
  end
end
