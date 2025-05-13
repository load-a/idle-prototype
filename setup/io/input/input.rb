# frozen_string_literal: true

require 'io/console'

require_relative 'response'
require_relative 'prompt'

module Input
  module_function

  def read_char
    character = ''

    ARGV.clear
    STDIN.raw do |stdin|
      character = stdin.getc
    end

    character
  end

  def ask(prompt, input_type = :default)
    ARGV.clear
    print Prompt.new(prompt, input_type)
    Response.new(gets)
  end

  def ask_line(prompt)
    ask(prompt, :line).line
  end

  def ask_number(prompt)
    ask(prompt, :number).number
  end

  def ask_char(prompt)
    print Prompt.new(prompt, :character)
    Response.new(read_char).character
  end

  def ask_digit(prompt)
    print Prompt.new(prompt, :digit)
    Response.new(read_char).digit
  end

  def confirm?(prompt)
    print Prompt.new(prompt, :confirm)
    Response.new(read_char).character == 'y'
  end

  def ask_keypress(prompt = 'Press any key to continue.')
    print Prompt.new(prompt, :none)
    read_char
  end

  def ask_option(*options, prompt: 'Make a selection: ')
    list = []

    options.each_with_index do |option, index|
      list << "[#{index + 1}] " + "#{option}".capitalize
    end

    prompt += (": \n" + list.join(', '))

    selection = if options.length <= 9
      self.ask_digit(prompt)
    else
      self.ask_number(prompt)
    end

    index = selection - 1

    return BLANK_RESPONSE if index.negative? || options[index].nil?

    Response.new(options[index], index: index)
  end
end
