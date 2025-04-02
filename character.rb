# frozen_string_literal: true

class Character
  attr_accessor :name, :health, :max_health, :power, :focus, :speed, :traits, :meter

  def initialize(name, power, focus, speed, traits)
    self.name = name
    self.max_health = 20
    self.health = max_health
    self.power = power
    self.focus = focus
    self.speed = speed
    self.meter = 0
    self.traits = traits
  end

  def charge_meter
    self.meter += power
    self.meter = focus if meter > focus
  end

  def charged?
    meter >= focus
  end

  def deplete_meter
    self.meter = 0
  end

  def down?
    health <= 0
  end

  def low_health?
    health <= max_health / 4
  end

  def full_heal
    self.health = max_health
  end

  def full_reset
    full_heal
    deplete_meter
  end

  def status
    format('%s: HP(%i/%i) P(%i) MP(%i/%i)%s%s', 
    name, health, max_health, power, meter, focus,
    (" BREAKER(#{traits[:breaker].name.capitalize})" if charged? && traits[:breaker].name != 'none'),
    (" CLUTCH(#{traits[:clutch].name.capitalize})" if low_health? && traits[:clutch].name != 'none'))
  end

  def to_s
    format('%s: HEALTH(%i/%i) POWER(%i) FOCUS(%i/%i) TRAITS(%s, %s, %s, %s)', 
      name, health, max_health, power, meter, focus,
      traits[:attack].name.capitalize, traits[:breaker].name.capitalize, 
      traits[:clutch].name.capitalize, traits[:defense].name.capitalize)
  end
end
