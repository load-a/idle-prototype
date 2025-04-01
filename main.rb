# frozen_string_literal: true

require_relative 'character'

require_relative 'trait'
require_relative 'dice'
require_relative 'game'
require_relative 'special'

require_relative 'setup'

listing = [CHARACTERS[:alyssa], CHARACTERS[:barney]]
players = listing.dup
count = 0

tally = {}

listing.each do |character|
  tally[character.name] = 0
end

100.times do

  count = 0
  listing.each(&:full_reset)

  loop do
    count += 1
    players.reverse!

    puts "~ Round #{count} ~".center(120), "#{listing[0].status_line} / #{listing[1].status_line}".center(120)
    Game.play_round(*players)

    if !listing[0].alive?
      puts "#{listing[1].name} wins!"
      tally[listing[1].name] += 1
      break 
    elsif !listing[1].alive?
      puts "#{listing[0].name} wins!"
      tally[listing[0].name] += 1
      break 
    end
  end
end
puts "Final Tally:", tally
