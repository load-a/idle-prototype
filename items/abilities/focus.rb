# frozen_string_literal: true

module FocusAbilities
  def opportunity(actor, action, round_data)
    return cant_focus(actor.name) if actor.focus.zero?

    modifier = Dice.roll(actor.focus)
    round_data[action] += modifier
    "#{actor.name} capitalized on an opportunity for +#{modifier} to #{action}"
  end

  def punishment(actor, action, round_data)
    return cant_focus(actor.name) if actor.focus.zero?

    focus = actor.focus
    round_data[action] += focus
    "#{actor.name} punished #{opponent(action, round_data).name}'s mistake for +#{focus} to #{action}"
  end

  ####

  def soothe_self(actor, _action, _round_data)
    return cant_focus(actor.name) if actor.focus.zero?

    mending = Dice.roll(actor.focus)
    actor.recover(mending)
    "#{actor.name} calmed down and got +#{mending} HEALTH"
  end

  def soothe_ally(actor, _action, round_data)
    return cant_focus(actor.name) if actor.focus.zero?

    ally = actor_team(actor, round_data).sample

    mending = Dice.roll(actor.focus)
    ally.recover(mending)

    if actor == ally
      "#{actor.name} soothed themself for +#{mending} FOCUS"
    else
      "#{actor.name} checked if #{ally.name} was ok. #{ally.name} recovered +#{mending} HEALTH"
    end
  end

  def soothe_team(actor, _action, round_data)
    return cant_focus(actor.name) if actor.focus.zero?

    mending = Dice.roll(actor.focus)

    actor_team(actor, round_data).each { |teammate| teammate.recover(mending) }

    "Everyone on #{actor.name}'s side took a deep breath and got back +#{mending} HEALTH"
  end

  def inspire_self(actor, _action, _round_data)
    return cant_focus(actor.name) if actor.focus.zero?

    charge = Dice.roll(actor.focus)
    actor.charge_focus(charge)
    "#{actor.name} looked inward and got +#{charge} FOCUS"
  end

  def inspire_ally(actor, _action, round_data)
    return cant_focus(actor.name) if actor.focus.zero?

    ally = actor_team(actor, round_data).sample

    charge = Dice.roll(actor.focus)
    ally.charge_focus(charge)

    if actor == ally
      "#{actor.name} got motivated for +#{charge} FOCUS"
    else
      "#{ally.name} saw #{actor.name} putting in the work and was inspired for +#{charge} FOCUS"
    end
  end

  def inspire_team(actor, _action, round_data)
    return cant_focus(actor.name) if actor.focus.zero?

    charge = Dice.roll(actor.focus)

    actor_team(actor, round_data).each { |teammate| teammate.charge_focus(charge) }

    "Everyone on #{actor.name}'s team was reinvigorated for +#{charge} FOCUS"
  end

  def cant_focus(actor_name)
    [
      "...but #{actor_name} just doesn't have it in them right now",
      "...but #{actor_name} isn't ready yet",
      "#{actor_team} tried to use their ability but couldn't",
      "...but #{actor_name} needs to charge up some more"
    ].sample
  end
end
