# frozen_string_literal: true

module CombatOutput
  def bracket(splitter = '...')
    right = cpu_team.members.map(&:brief)
    left = player_team.members.map {|member| member.brief(true)}
    sign = []

    [right, left].map(&:length).max.times do |number|
      sign << '%48s %s %-48s' % [left[number], splitter, right[number]]
    end

    sign
  end

  def alert(message, front_symbol = '!! ', back_symbol = nil)
    back_symbol = front_symbol.reverse if back_symbol.nil?

    '%s%s%s' % [front_symbol, message, back_symbol]
  end

  def bullet(amount) 
    if amount.positive? 
      '-- ' 
    elsif amount.zero? 
      '~~ ' 
    else 
      '++ ' 
    end 
  end
end
