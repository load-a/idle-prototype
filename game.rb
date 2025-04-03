# frozen_string_literal: true

module Game
  module_function

  Context = Struct.new(:attacker, :defender, :encounter, :special_moves)
  Encounter = Struct.new(:attack, :defense, :counters)

  # TODO: Method is too big; trim it down somehow
  def round_of_combat(attacker, defender)
    # Base attack, defense and counters calculated
    # Round Context created
    battle_log = []
    context = Context.new(attacker, defender, roll_encounter(attacker, defender), {attack: [], defense: []})
    attack_damage = 0
    counter_damage = 0
    breaker_damage = 0

    # Both character's traits are added to context
    add_traits(context, :attack)
    add_traits(context, :defense)

    # Attacker winds up
    battle_log << "#{attacker.name} prepares to attack."
    
    if context.special_moves[:attack].include? :attack
      battle_log << "#{attacker.name} critted and uses #{attacker.traits[:attack].name}!"
      resolve_crit_attack(context)
    end

    # Defender gets some hits in
    counter_damage = counter_attack(defender, context.encounter.counters)
    # battle_log << "#{context.encounter.attack.result} / #{defender.speed} = #{context.encounter.counters}"
    if counter_damage > 0
      battle_log << "#{defender.name} got #{context.encounter.counters} hits in before the attack landed."

      take_damage(attacker, counter_damage) 
      battle_log << damage_text(attacker, counter_damage, 'counter ')
    end

    # Defender raises their guard
    resolve_crit_defense(context)
    battle_log << "#{defender.name} put up #{context.encounter.defense.result} defense."

    # Attack damage calculated
    attack_damage = context.encounter.attack.result - context.encounter.defense.result

    # Attack follows through
    battle_log << "#{attacker.name} attacked for #{context.encounter.attack.result} damage!"
    take_damage(defender, attack_damage)
    battle_log << damage_text(defender, attack_damage)

    # Attacker uses breaker
    if context.special_moves[:attack].include? :breaker
      battle_log << "FOLLOW UP: #{attacker.name} comes back with #{attacker.traits[:breaker].name}!" 
      breaker_damage = resolve_breaker(context)
      attacker.deplete_meter
    end

    take_damage(defender, breaker_damage)
    battle_log << damage_text(defender, breaker_damage, 'extra ') if breaker_damage > 0

    # Defender uses clutch
    if context.special_moves[:defense].include? :clutch
      battle_log << "#{defender.name} tries to clutch this with #{defender.traits[:clutch].name}!" 
      resolve_clutch(context)
    end

    battle_log
  end

  def roll_encounter(attacker, defender)
    attack = Dice.roll(attacker.power)
    defense = Dice.roll(defender.power)
    counters = attack.result / defender.speed

    Encounter.new(attack, defense, counters)
  end

  def add_traits(context, type)
    character = context.send(type_to_character(type))

    # Add breaker before critical charge
    context.special_moves[type] << :breaker if character.charged? && character.traits[:breaker].name != 'none'

    if context.encounter.send(type).crit
      context.special_moves[type] << type unless character.traits[type].name == 'none'
      character.charge_meter
    end

    context.special_moves[type] << :clutch if character.low_health? && character.traits[:clutch].name != 'none'
  end

  def type_to_character(type)
    type == :attack ? :attacker : :defender
  end

  def resolve_crit_attack(context)
    return unless context.special_moves[:attack].include? :attack

    CriticalAttacks.send(context.attacker.traits[:attack].name, context)
  end

  def resolve_crit_defense(context)
    return unless context.special_moves[:defense].include? :defense

    CriticalDefenses.send(context.defender.traits[:defense].name, context)
  end

  def resolve_breaker(context)
    return unless context.special_moves[:attack].include? :breaker

    Breakers.send(context.attacker.traits[:breaker].name, context)
  end

  def resolve_clutch(context)
    return unless context.special_moves[:defense].include? :clutch

    ClutchPlays.send(context.defender.traits[:clutch].name, context)
  end

  def counter_attack(character, hits)
    return 0 if hits.zero?

    total = 0

    hits.times do 
      total += Dice.roll(character.power).result
    end

    total
  end

  def take_damage(character, damage)
    character.health -= [damage, 0].max
    character.health = 0 if character.health < 0
  end

  def damage_text(character, damage, modifier = '')
    if damage.zero?
      "#{character.name} dodged it!"
    elsif damage < 0
      "#{character.name} blocked it!"
    else
      "* #{character.name} took #{damage} #{modifier}damage! *"
    end
  end
end
