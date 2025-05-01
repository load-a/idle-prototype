# frozen_string_literal: true

module CombatMethods
  def process_critical_attack(attacker, round)
    log << alert('Nice offense', '// ')

    return if attacker.traits[:attack].id == :none

    # log << alert(critical_message, '^^ ')
    log << alert(attacker.use_item(:attack, round), '   ')
  end

  def apply_counter_damage(attacker, defender, round)
    counter_damage = round[:counter]

    attacker.take_damage(counter_damage)

    log << "#{defender.name} got some hits in during the windup"
    log << alert("#{attacker.name} took #{counter_damage} counter damage", bullet(counter_damage))
  end

  def process_critical_defense(defender, round)
    log << alert('Solid defense', '// ')

    return if defender.traits[:defense].id == :none

    # log << alert(critical_message, '^^ ')
    log << alert(defender.use_item(:defense, round), '   ')
  end

  def process_breaker(attacker, round)
    return if attacker.traits[:breaker].id == :none

    log << alert("#{attacker.name} unleashed their Breaker", '// ')
    log << alert(attacker.use_item(:breaker, round), '   ')

    attacker.reset_focus
  end

  def process_clutch(defender, round)
    return if defender.traits[:clutch] == ABILITIES[:none]

    saving_throw = Dice.roll(20)

    return log << alert("#{defender.name} tried to clutch up but choked", '.. ') if saving_throw < defender.power

    log << alert("#{defender.name} clutched it!", '// ')
    log << alert(defender.use_item(:clutch, round), '   ')
  end

  def apply_encounter_damage(defender, round)
    damage = [round[:attack] - round[:defense], 0].max
    defender.take_damage(damage)
    log << alert("#{defender.name} took #{damage} damage", bullet(damage))
  end

  def alert_downs(attacking_team, defending_team)
    attacking_team.members.each do |character|
      log << alert("#{character.name} is down") if character.down?
    end

    defending_team.members.each do |character|
      log << alert("#{character.name} is down") if character.down?
    end
  end
end
