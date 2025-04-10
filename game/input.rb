# frozen_string_literal: true

module Input
  DEFAULT_STRING = ']?['.freeze

  def ask(prompt, character_limit = 1)
    puts prompt
    get_string(character_limit)
  end

  def get_string(character_limit = 1)
    gets.chomp[0..character_limit - 1]&.downcase || DEFAULT_STRING
  end

  def ask_number(prompt, digits)
    puts prompt
    get_number(digits)
  end

  def get_number(digits = 1)
    pick = gets.chomp[0..digits - 1]&.downcase || '0'
    pick.to_i
  end
end

