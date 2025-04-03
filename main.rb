# frozen_string_literal: true

require_relative 'character'

require_relative 'trait'
require_relative 'dice'
require_relative 'game'
require_relative 'special'

require_relative 'setup'

players = [CHARACTERS[:alyssa], CHARACTERS[:barney]]
order = players.dup

tally = {
  average_rounds: []
}

players.each {|character| tally[character.name] = 0}

round = 0
game_match = 0
simulations = 1000

sample = rand(1..simulations)
# sample = simulations + 1

def status_text(players, width)
  side_length = (width - 4) / 2
  right = players[0].status.rjust(side_length)
  left = players[1].status.ljust(side_length)
  '%s vs %s' % [right, left]
end

system 'clear'

simulations.times do
  game_match += 1
  round = 0

  players.each(&:full_reset)
  puts "-- Match #{game_match} --".center(120) if game_match == sample

  loop do
    round += 1
    order.reverse!

    puts "~~Round #{round}~~".center(120) if game_match == sample
    puts status_text(players, 120) if game_match == sample

    battle_log = Game.round_of_combat(order[0], order[1])
    puts battle_log.join("\n  ") if game_match == sample

    if players[0].down?
      puts "#{players[1].name} wins!" if game_match == sample
      tally[players[1].name] += 1
      break
    elsif players[1].down?
      puts "#{players[0].name} wins!" if game_match == sample
      tally[players[0].name] += 1
      break
    end
  end

  tally[:average_rounds] << round
end

tally[:average_rounds] = tally[:average_rounds].sum / tally[:average_rounds].length

puts "Final Tally:", tally

# Notes:
# The person to attack first seems to have a slight disadvantage

