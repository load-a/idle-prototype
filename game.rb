# frozen_string_literal: true

module Game
  module_function

  Context = Struct.new(:attacker, :defender, :encounter, :specials)
  Encounter = Struct.new(:attack, :defense)

  def run_combat(attacker, defender)
    attack = Dice.roll(attacker.power)
    defense = Dice.roll(defender.power)

    attacker.charge_meter if attack.crit
    defender.charge_meter if defense.crit

    Context.new(attacker, defender, Encounter.new(attack, defense), {attacker: [], defender: []})
  end

  def add_crit_moves(context)
    if context.encounter.attack.crit
      context.specials[:attacker] << context.attacker.specials[:attack]
    end

    if context.encounter.defense.crit
      context.specials[:defender] << context.defender.specials[:defense]
    end
  end

  def add_clutch_moves(context)
    # if context.attacker.low_health?
    #   context.specials[:attacker] << context.attacker.specials[:clutch]
    # end

    if context.defender.low_health?
      context.specials[:defender] << context.defender.specials[:clutch]
    end
  end

  def add_breaker_moves(context)
    if context.attacker.charged?
      context.specials[:attacker] << context.attacker.specials[:breaker]
    end

    if context.defender.charged?
      context.specials[:defender] << context.defender.specials[:breaker]
    end 
  end

  def use_active_traits(context)
    context.specials[:attacker].each do |action|
      next unless action.attack?
      Special.send(action.name, context, :attack)
    end

    context.specials[:defender].each do |action|
      next unless action.defense?
      Special.send(action.name, context, :defense)
    end
  end

  def use_breaker(context)
    context.specials[:attacker].each do |action|
      next unless action.breaker?

      Special.send(action.name.downcase, context, :attack)
      context.attacker.deplete_meter
    end
  end

  def inflict_damage(context)
    damage = [context.encounter.attack.result - context.encounter.defense.result, 0].max

    context.defender.health -= damage

    if damage.zero?
      puts "#{context.defender.name} put up #{context.encounter.defense.result} defense!", "The attack missed!"
    else
      puts "#{context.defender.name} blocked #{context.encounter.defense.result} and took #{damage} damage!"
    end

    context
  end

  def play_round(attacker, defender)
    context = run_combat(attacker, defender)

    puts "#{context.attacker.name} attacks #{context.defender.name} for #{context.encounter.attack.result} damage!"

    add_crit_moves(context)
    add_clutch_moves(context)
    add_breaker_moves(context)

    use_active_traits(context)
    use_breaker(context)

    inflict_damage(context)
  end
end
