# frozen_string_literal: true

module SpeedAbilities
  def side_step(actor, action, round_data)
    return "... but #{actor.name} is too slow to use Side Step" if actor.speed_multiplier <= 1

    round_data[action] = (round_data[action] * actor.speed_multiplier).round

    "#{actor.name} stepped to the side and multiplied their #{action} by #{actor.speed_multiplier}"
  end

  def quick_step(actor, action, round_data)    
    boost = (actor.proficiency_value * actor.speed_multiplier).round
    round_data[action] += boost
    "#{actor.name} got +#{boost} to #{action} using their quick footwork"
  end
end
