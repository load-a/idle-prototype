# frozen_string_literal: true

module FocusAbilities
  def opportunity(actor, action, round_data)
    modifier = Dice.roll(actor.focus)
    round_data[action] += modifier
    "#{actor.name} capitalized on an opportunity for +#{modifier} to #{action}"
  end

  def punishment(actor, action, round_data)
    focus = actor.focus
    round_data[action] += focus
    "#{actor.name} punished #{opponent(action, round_data).name}'s mistake for +#{focus} to #{action}"
  end
end
