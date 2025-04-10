# frozen_string_literal: true

module Information
  def status
    format('%s: HP(%i/%i) MP(%i/%i) P(%i) S(%i) %s%s', 
    name, health, max_health, focus, max_focus, power, speed,
    (" BREAKER(#{traits[:breaker].name.capitalize})" if charged? && traits[:breaker].name != 'none'),
    (" CLUTCH(#{traits[:clutch].name.capitalize})" if low_health? && traits[:clutch].name != 'none'))
  end

  def to_s
    format('%16s: HEALTH(%i/%i) FOCUS(%i/%i) POWER(%i) SPEED(%i) TRAITS(%s, %s, %s, %s)', 
      name, health, max_health, focus, max_focus, power, speed,
      traits[:attack].name.capitalize, traits[:breaker].name.capitalize, 
      traits[:clutch].name.capitalize, traits[:defense].name.capitalize)
  end

  def attribute_chart
    {
      name: "~#{name}'s Stats~",
      health: format("%-6s: %2i/%2i", 'Health', health, max_health),
      focus: format("%-6s: %2i/%2i", 'Focus', focus, max_focus),
      power: format("%-6s: %2i", 'Power', power),
      speed: format("%-6s: %2i", 'Speed', speed),
      attack: format("%-16s: %s", 'Critical Attack', traits[:attack].name),
      defense: format("%-16s: %s", 'Critical Defense', traits[:defense].name),
      breaker: format("%-16s: %s", 'Focus Breaker', traits[:breaker].name),
      clutch: format("%-16s: %s", 'Clutch Play', traits[:clutch].name),
    }
  end
end

class Character
  include Information

  attr_accessor :name, :health, :max_health, :power, :max_focus, :speed, 
  :traits, :focus, :behavior, :assignment, :schedule, :tasks, :cost, :max_cost

  def initialize(name, health, power, max_focus, speed)
    self.name = name
    self.max_health = health
    self.power = power
    self.max_focus = max_focus
    self.speed = speed
    self.traits = {}
    self.behavior = {}
    self.schedule = []
    self.assignment = "rest"

    full_reset
  end

  def charge_meter
    self.focus += power
    self.focus = max_focus if focus > max_focus
  end

  def charged?
    focus >= max_focus
  end

  def deplete_meter
    self.focus = 0
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

  def reset_cost
    self.cost = max_cost
  end

  def pass_time(hour)
    do_task(hour)
  end

  def do_task(hour)
    case schedule[hour]
    when :sleep
      self.health = 20 if health < 20
    when :rest
      self.health += 1 unless health > max_health + 10
    when :train
      self.focus += 1 unless focus >= max_focus
    when :job
      self.cost -= 1
    end
  end

  def do_assignment
    case_assignment
  end
end
