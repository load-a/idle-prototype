# frozen_string_literal: true

module CombatMethods
  def process_critical_attack(attacker, round)
    log << "Critical attack!" 
      
    return if attacker.traits[:attack].id == :none

    log << "#{attacker.name} used #{attacker.traits[:attack].id}"
    critical = attacker.use_trait(:attack, round)
    log << alert(critical, '^^ ')
  end

  def apply_counter_damage(attacker, defender, round)
    counter_damage = round[:counter]

    attacker.take_damage(counter_damage)

    log << "#{defender.name} got some hits in"
    log << alert("#{attacker.name} took #{counter_damage} counter damage", bullet(counter_damage))
  end

  def process_critical_defense(defender, round)
    log << "Critical defense!"

    return if defender.traits[:defense].id == :none

    log << "#{defender.name} used #{defender.traits[:defense].id}"
    critical = defender.use_trait(:defense, round)
    log << alert(critical, '^^ ')
  end

  def process_breaker(attacker, round)
    return if attacker.traits[:breaker].id == :none

    attacker.reset_focus

    log << "#{attacker.name} uses BREAKER" 
    log << attacker.use_trait(:breaker, round)
  end

  def process_clutch(defender, round)
    return if defender.traits[:clutch] == TRAITS[:none]

    saving_throw = Dice.roll(20).result

    return log << alert("#{defender.name} couldn't hang...", 'vv ') if saving_throw < defender.power

    log << "Clutch!"
    log << alert(defender.use_trait(:clutch, round), '^^ ')
  end

  def apply_encounter_damage(defender, round)
    damage = [round[:attack] - round[:defense], 0].max
    defender.take_damage(damage)
    log << alert("#{defender.name} took #{damage} damage", bullet(damage))
  end

  def check_defeats(teams)
    # Alert defeats
    teams.map(&:members).flatten.each do |character|
      if character.down?
        log << alert("#{character.name} is defeated")
      end
    end
  end
end
