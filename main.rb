# frozen_string_literal: true

require_relative 'character'

require_relative 'trait'
require_relative 'dice'
require_relative 'game'
require_relative 'special'

require_relative 'setup'

teams = [
  [CHARACTERS[:alyssa], CHARACTERS[:xia], CHARACTERS[:yumi], CHARACTERS[:tomoe]], 
  [CHARACTERS[:isolde], CHARACTERS[:melvin], CHARACTERS[:jamal], CHARACTERS[:ray]]
]

match = Game.play_match(*teams)

system 'clear'
puts match.join("\n")
