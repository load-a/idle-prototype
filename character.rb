# frozen_string_literal: true

class Character
  attr_accessor :name, :health, :max_health, :power, :specials, :lives

  def initialize(name, power, specials)
    self.name = name
    self.max_health = 60 - power
    self.health = max_health
    self.power = power
    self.specials = specials
    self.lives = 3
  end

  def alive?
    health > 0
  end

  def low_health?
    health <= max_health / 4
  end

  def status_line
    format('%s: HP(%i/%i) POWER(%i) %s %s', 
    name, health, max_health, power, 
    ("PASSIVE(#{specials[:passive].capitalize})" unless specials[:passive] == 'none'),
    ("CLUTCH(#{specials[:clutch].capitalize})" if low_health? && specials[:clutch] != 'none'))
  end

  def to_s
    format('%s: HP(%i/%i) POWER(%i) TRAITS(%s, %s, %s, %s)', 
      name, health, max_health, power, 
      specials[:attack].capitalize, specials[:defense].capitalize, 
      specials[:passive].capitalize, specials[:clutch].capitalize)
  end
end
