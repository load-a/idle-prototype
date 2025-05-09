# frozen_string_literal: true

require_relative 'team'

module Information
  def status_bar(current, max, length = 10)
    current = current.clamp(0, max)
    bars = ((current.to_f / max) * length).round

    raise "BARS #{current} #{max} #{length} :: bars#{bars}" if bars.negative?

    lines = length - bars

    raise "LINES #{current} #{max} #{length} :: bars#{bars} :: lines#{lines}" if lines.negative?

    "#{'█' * bars}#{'-' * lines}"
  end

  def brief(reverse = false)
    if reverse
      format('(%s)MP (%s %02i/%02i)HP :%16s', status_bar(focus, max_focus).reverse,
             status_bar(health, max_health).reverse, health, max_health, name)
    else
      format('%-16s: HP(%02i/%02i %s) MP(%s)', name, health, max_health, status_bar(health, max_health),
             status_bar(focus, max_focus))
    end
  end

  def to_s
    format('%16s: HEALTH(%i/%i) FOCUS(%i/%i) POWER(%i) SPEED(%i) ABILITIES(%s, %s, %s, %s)',
           name, health, max_health, focus, max_focus, power, speed,
           traits[:attack].id.capitalize, traits[:breaker].id.capitalize,
           traits[:clutch].id.capitalize, traits[:defense].id.capitalize)
  end

  def attribute_chart
    speed_line = 'Speed : %2i x%s %s' 
    
    {
      name: "~#{name}'s Stats~",
      health: format('%-6s: %2i/%2i', 'Health', health, max_health),
      power: format('%-6s: %2i %s', 'Power', power, ('*' if proficiency == :power)),
      focus: format('%-6s: %2i/%2i %s', 'Focus', focus, max_focus, ('*' if proficiency == :focus)),
      speed: speed_line % [speed, speed_multiplier, ("* [#{Dice.inverse_die(speed)}]" if proficiency == :speed)],
      attack: format('%-13s: %s', 'Crit. Attack', traits[:attack].name),
      defense: format('%-13s: %s', 'Crit. Defense', traits[:defense].name),
      breaker: format('%-13s: %s', 'Focus Breaker', traits[:breaker].name),
      clutch: format('%-13s: %s', 'Clutch Move', traits[:clutch].name)
    }
  end
end

class Character
  include Information

  attr_accessor :name, :id, :health, :max_health, :power, :max_focus, :speed,
                :traits, :focus, :behavior, :assignment, :schedule, :tasks, :cost, :max_cost, :speed_multiplier

  def initialize(name, id, health, power, max_focus, speed)
    self.name = name
    self.id = id
    self.max_health = health
    self.power = power
    self.max_focus = max_focus
    self.speed = speed
    self.traits = {}
    self.behavior = {}
    self.schedule = []
    self.assignment = 'free'
    self.speed_multiplier = SPEED_MULTIPLIER[speed.to_s]

    full_reset
  end

  def dice
    {
      power: power,
      focus: max_focus,
      speed: speed
    }
  end

  # @return [Symbol]
  def proficiency
    list = {
      power: power,
      focus: focus == power ? focus + 1 : focus,
      speed: Dice.inverse_die(speed)
    }
    main = list.values.max
    list.key(main)
  end

  # @return [Integer]
  def proficiency_value
    {
      power: power,
      focus: focus,
      speed: Dice.inverse_die(speed)
    }.values.max
  end

  def promult
    (proficiency_value * speed_multiplier).round
  end

  def take_damage(damage)
    self.health -= damage
    self.health = 0 if health < 0
  end

  def charge_focus(ammount = 1)
    self.focus += ammount
    self.focus = max_focus if focus > max_focus
  end

  def charged?
    focus >= max_focus
  end

  def reset_focus
    self.focus = 0
  end

  def down?
    health <= 0
  end

  def up?
    health.positive?
  end

  def low_health?
    health <= max_health / 4
  end

  def same_as?(character)
    id == character.id
  end

  def full_heal
    self.health = max_health
  end

  def full_reset
    full_heal
    reset_focus
  end

  def recover(amount = 1)
    self.health += amount
    self.health = max_health if self.health > max_health
  end
  alias heal recover

  def reset_cost
    self.cost = max_cost
  end

  def set_schedule
    schedule.clear

    sleeping = []
    working = []

    behavior.each do |activity, max_time|
      case activity
      when :sleep
        sleeping += Array.new(rand(max_time - 3..max_time), :sleep)
      when :job
        working += Array.new(rand(0..max_time), :work)
      else
        schedule << Array.new(rand(0..max_time), activity)
      end
    end

    schedule.fill(:free, schedule.length, 24 - schedule.length)
    schedule.flatten!
    self.schedule = schedule.shuffle.sample(24 - (working + sleeping).length)
    schedule.insert(rand(0..schedule.length - working.length), *working)
    schedule.prepend(sleeping)
    schedule.flatten!

    schedule.rotate!(rand(2..5))
  end

  def use_item(trait, encounter)
    case traits[trait].type
    when :abilities
      use_ability(trait, encounter)
    when :consumables
      message = Consumables.send(traits[trait].id, self)
      traits[trait] = NO_ITEM
      message
    when :none
      '...but nothing happened'
    else
      raise "Invalid item in #{name}'s #{trait} (this should only be an Ability or Consumable): #{traits[trait]}"
    end
  end

  def upgrade_stat(stat, levels)
    case stat.to_sym
    when :power, :focus
      current_level = Dice.find_level(send(stat))
      new_level = Dice.level((current_level + levels).clamp(1, 7))
      send("#{stat}=", new_level)
    when :health
    when :speed
    else
      raise "#{name} cannot upgrade stat: #{stat}"
    end
  end

  def use_ability(trait, encounter)
    case trait
    when :breaker
      Abilities.send(traits[trait].id, self, :attack, encounter)
    when :clutch
      Abilities.send(traits[trait].id, self, :defense, encounter)
    else
      Abilities.send(traits[trait].id, self, trait, encounter)
    end
  end

  def from_zero
    character = dup
    character.power = 4
    character.max_health = 20
    character.max_focus = 20
    character.speed = 20
    character.full_reset

    character.traits.transform_values! { |_trait| Trait.new(:none) }

    character
  end
end
