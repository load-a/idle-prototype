# frozen_string_literal: true

module Game
  module_function

  Context = Struct.new(:attacker, :defender, :encounter, :specials)
  Encounter = Struct.new(:attack, :defense)

  def run_combat(attacker, defender)
    attack = Dice.roll(attacker.power)
    defense = Dice.roll(defender.power)

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

  def use_active_traits(context)
    context.specials[:attacker].each do |action|
      Special.send(action, context, :attack)
    end

    context.specials[:defender].each do |action|
      Special.send(action, context, :defense)
    end
  end

  def use_passive_traits(context)
  end

  def inflict_damage(context)
    damage = [context.encounter.attack.result - context.encounter.defense.result, 0].max

    context.defender.health -= damage

    if damage.zero?
      puts "The attack missed!"
    else
      puts "#{context.defender.name} blocked #{context.encounter.defense.result} and took #{damage} damage!"
    end
  end

  def play_round(attacker, defender)
    context = run_combat(attacker, defender)

    puts "#{context.attacker.name} attacks #{context.defender.name} for #{context.encounter.attack.result} damage!"

    add_crit_moves(context)
    add_clutch_moves(context)

    use_active_traits(context)
    use_passive_traits(context)

    inflict_damage(context)

    # puts context.specials
    # puts context.encounter
  end
end
