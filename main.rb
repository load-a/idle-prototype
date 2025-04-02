# frozen_string_literal: true

require_relative 'character'

require_relative 'trait'
require_relative 'dice'
require_relative 'game'
require_relative 'special'

require_relative 'setup'

players = [CHARACTERS[:alyssa], CHARACTERS[:barney]]
order = players.dup

round = 0

def status_text(players, width)
  side_length = (width - 4) / 2
  right = players[0].status.rjust(side_length)
  left = players[1].status.ljust(side_length)
  '%s vs %s' % [right, left]
end

loop do
  round += 1
  order.reverse!

  puts "~~Round #{round}~~".center(120)
  puts status_text(players, 120)

  battle_log = Game.round_of_combat(order[0], order[1])
  puts battle_log.join("\n  ")

  if players[0].down?
    puts "#{players[1].name} wins!"
    break
  elsif players[1].down?
    puts "#{players[0].name} wins!"
    break
  end
end
