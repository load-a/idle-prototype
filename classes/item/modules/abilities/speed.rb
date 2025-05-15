# frozen_string_literal: true

module SpeedAbilities
  def side_step(actor, action, round_data)
    return "... but #{actor.name} is too slow to use Side Step" if actor.speed_multiplier <= 1

    round_data[action] = (round_data[action] * actor.speed_multiplier).round

    "#{actor.name} stepped into a solid position, multiplying their #{action} by #{actor.speed_multiplier}"
  end

  def quick_step(actor, action, round_data)
    boost = Dice.roll(actor.promult)
    round_data[action] += boost
    "#{actor.name} got +#{boost} to #{action} using their quick footwork"
  end

  def boost_self(actor, _action, _round_data)
    mending = Dice.roll(actor.promult)
    actor.recover(mending)
    "#{actor.name} healed +#{mending} HEALTH"
  end

  def boost_ally(actor, _action, round_data)
    ally = actor_team(actor, round_data).sample

    mending = Dice.roll(actor.promult)
    ally.recover(mending)

    "#{actor.name} healed #{ally.name} for +#{mending} HEALTH"
  end

  def boost_team(actor, _action, round_data)
    mending = Dice.roll(actor.promult)

    actor_team(actor, round_data).each { |teammate| teammate.recover(mending) }

    "#{actor.name}'s whole squad restored +#{mending} HEALTH"
  end

  def motivate_self(actor, _action, _round_data)
    charge = Dice.roll(actor.promult)
    actor.charge_focus(charge)
    "#{actor.name} got ready to throw down and gained +#{charge} FOCUS"
  end

  def motivate_ally(actor, _action, round_data)
    ally = actor_team(actor, round_data).sample

    charge = Dice.roll(actor.promult)
    ally.charge_focus(charge)

    if ally == actor
      "#{actor.name} gassed themself up for +#{charge} FOCUS"
    else
      "#{actor.name} gassed #{ally.name} up for +#{charge} FOCUS"
    end
  end

  def motivate_team(actor, _action, round_data)
    charge = Dice.roll(actor.promult)

    actor_team(actor, round_data).each { |teammate| teammate.charge_focus(charge) }

    "#{actor.name}'s whole team got hype for +#{charge} FOCUS"
  end
end
