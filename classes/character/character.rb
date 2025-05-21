# frozen_string_literal: true

require_relative 'information'

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

  def uncharge?
    return false unless charged?

    if Dice.roll(max_health) > health
      reset_focus
      true
    else
      false
    end
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
    # character.power = 4
    # character.max_health = 20
    # character.max_focus = 20
    # character.speed = 20
    character.full_reset

    character.traits.transform_values! { |_trait| NO_ITEM }

    character
  end

  def too_weak?
    health < 20
  end

  def serialize
    {
      id: id,
      stats: {
        power: power,
        max_focus: max_focus,
        speed: speed
      },
      traits: {
        attack: traits[:attack].id,
        defense: traits[:defense].id,
        clutch: traits[:clutch].id,
        breaker: traits[:breaker].id
      }
    }
  end

  def deserialize(serial_hash)
    duplicate = dup

    serial_hash['traits'].each do |trait, item_id|
      duplicate.traits[trait.to_sym] = ABILITIES[item_id.to_sym] || CONSUMABLES[item_id.to_sym] || NO_ITEM
    end

    duplicate
  end
end
