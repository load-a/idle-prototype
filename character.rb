# frozen_string_literal: true

module Information
  def status_bar(stat, max, length = 10)
    bars = ((stat.to_f / max) * length).ceil
    lines = length - bars

    "#{'█' * bars}#{'-' * lines}"
  end

  def brief(reverse = false)
    if reverse
      '(%s)MP (%s)HP :%16s' % [status_bar(focus, max_focus).reverse, status_bar(health, max_health).reverse, name]
    else
      '%-16s: HP(%s) MP(%s)' % [name, status_bar(health, max_health), status_bar(focus, max_focus)]
    end
  end

  def status
    format('%s: HP(%2i/%2i) MP(%2i/%2i) P(%2i) S(%2i) %s%s', 
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
    self.assignment = "free"

    full_reset
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

  def low_health?
    health <= max_health / 4
  end

  def full_heal
    self.health = max_health
  end

  def full_reset
    full_heal
    reset_focus
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
