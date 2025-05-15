# frozen_string_literal: true

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
      speed: format(speed_line, speed, speed_multiplier, ("* [#{Dice.inverse_die(speed)}]" if proficiency == :speed)),
      attack: format('%-13s: %s', 'Crit. Attack', traits[:attack].name),
      defense: format('%-13s: %s', 'Crit. Defense', traits[:defense].name),
      breaker: format('%-13s: %s', 'Focus Breaker', traits[:breaker].name),
      clutch: format('%-13s: %s', 'Clutch Move', traits[:clutch].name)
    }
  end
end
