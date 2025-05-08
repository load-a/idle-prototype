# frozen_string_literal: true

module ReductionAbilities
  def intimidate(actor, action, round_data)
    opponent_action = opposing_action(action)
    reduction = Dice.roll(actor.power)
    
    round_data[opponent_action] = [round_data[opponent_action] - reduction, 0].max
    
    "#{actor.name} got all up in #{opponent(action, round_data).name}'s face for -#{reduction} #{opponent_action}"
  end

  def anticipate(actor, action, round_data)
    return cant_focus if actor.focus.zero?

    opponent_action = opposing_action(action)
    reduction = Dice.roll(actor.focus)
    
    round_data[opponent_action] = [round_data[opponent_action] - reduction, 0].max
    
    "#{actor.name} anticipated the #{opponent_action} and reduced it by #{reduction}"
  end

  def dodge(actor, action, round_data)
    opponent_action = opposing_action(action)
    reduction = Dice.roll(actor.promult)
    
    round_data[opponent_action] = [round_data[opponent_action] - reduction, 0].max
    
    "#{actor.name} leapt and reduced the #{opponent_action} by #{reduction}"
  end
end
