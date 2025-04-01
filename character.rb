# frozen_string_literal: true

class Character
  attr_accessor :name, :health, :max_health, :power, :focus, :specials, :meter

  def initialize(name, power, focus, specials)
    self.name = name
    self.max_health = 20
    self.health = max_health
    self.power = power
    self.focus = focus
    self.meter = 0
    self.specials = specials
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

  def alive?
    health > 0
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

  def status_line
    format('%s: HP(%i/%i) P(%i) MP(%i/%i)%s%s', 
    name, health, max_health, power, meter, focus,
    (" BREAKER(#{specials[:breaker].name.capitalize})" if charged? && specials[:breaker].name != 'none'),
    (" CLUTCH(#{specials[:clutch].name.capitalize})" if low_health? && specials[:clutch].name != 'none'))
  end

  def to_s
    format('%s: HEALTH(%i/%i) POWER(%i) FOCUS(%i/%i) TRAITS(%s, %s, %s, %s)', 
      name, health, max_health, power, meter, focus,
      specials[:attack].name.capitalize, specials[:breaker].name.capitalize, 
      specials[:clutch].name.capitalize, specials[:defense].name.capitalize)
  end
end
