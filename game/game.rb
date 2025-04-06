# frozen_string_literal: true

require_relative 'calendar'
require_relative 'combat'
require_relative 'off_time'

class Game
  attr_accessor :calendar, :player, :team, :next_opponent, :shop

  def initialize
    self.calendar = Calendar.new
    self.player = nil
    self.team = []
    self.next_opponent = nil
    self.shop = []

    pick_character
  end

  def pick_character
    letter = ''

    loop do 
      puts 'Please enter your favorite letter'
      letter = gets.chomp.upcase[0]

      break if letter =~ /[A-Z]/
    end
    
    pick = CHARACTERS.select {|id, character| character.name.start_with?(letter)}.values[0]

    self.player = pick

    puts "you picked", player
  end
end
