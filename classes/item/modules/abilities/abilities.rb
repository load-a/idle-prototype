# frozen_string_literal: true

require_relative 'power'
require_relative 'focus'
require_relative 'speed'
require_relative 'reductions'

module Abilities
  extend PowerAbilities
  extend FocusAbilities
  extend SpeedAbilities
  extend ReductionAbilities

  module_function

  def berserk(actor, _action, round_data)
    damage = (actor.health / 2).floor

    return "#{actor.name} tried to go berserk but couldn't" if damage.zero?

    target = opposing_team(actor, round_data).sample

    actor.take_damage(damage)
    target.take_damage(damage)

    "#{actor.name} went berserk!\n   #{actor.name} and #{target.name} both took #{damage} damage"
  end

  def snipe(actor, _action, round_data)
    target = opposing_team(actor, round_data).sample

    target.take_damage(actor.power)

    "#{actor.name} sniped #{target.name} for #{actor.power} damage"
  end

  def crossfire(actor, _action, round_data)
    target = opposing_team(actor, round_data).sample

    target.take_damage(Dice.roll(actor.power))

    "#{actor.name} came out swinging!\n   #{target.name} took #{actor.power} damage in the commotion"
  end

  def backup(actor, action, round_data)
    return "#{actor.name} called for backup... but no one could come" if actor_team(actor, round_data).length <= 1

    backup = allies(actor, round_data)
    ally = backup.sample
    assist = Dice.roll(ally.power)

    round_data[action] += assist

    "#{actor.name} called for backup. #{ally.name} helped out with +#{assist} #{action}"
  end

  def gang_up(actor, action, round_data)
    return "#{actor.name} called for the squad... but they're not around" if allies(actor, round_data).empty?

    backup = allies(actor, round_data)
    assist = 0

    backup.each do |ally|
      stat = ally.proficency
      assist += Dice.roll(ally.proficiency_value)
    end

    round_data[action] += assist

    "#{actor.name}'s whole squad came out to help with +#{assist} #{action}"
  end

  def mimicry(actor, action, round_data)
    abilities = ABILITIES.keys.select {|id| id != :mimicry}
    send(abilities.sample, actor, action, round_data)
  end

  def mastery(actor, action, round_data)
    full_power = (actor.power + actor.max_focus) * SPEED_MULTIPLIER[actor.speed.to_s]
    round_data[action] += full_power.round
    "#{actor.name}'s eyes are glowing..."
  end

  def opposing_action(action)
    action == :attack ? :defense : :attack
  end

  def opponent(action, round_data)
    role = (action == :attack ? :defender : :attacker)
    round_data.send(role)
  end

  def actor_team(actor, round_data)
    team_type = round_data[:attack_team].include?(actor) ? :attack_team : :defense_team
    round_data[team_type].members
  end

  def allies(actor, round_data)
    team_type = round_data[:attack_team].include?(actor) ? :attack_team : :defense_team
    team = round_data[team_type]
    team.members.select { |teammate| teammate != actor }
  end

  def opposing_team(actor, round_data)
    team_type = round_data[:attack_team].include?(actor) ? :defense_team : :attack_team
    round_data[team_type].members
  end
end
