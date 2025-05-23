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
      return '?' if character =~ /\W/
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
    print Prompt.new(Rainbow(prompt).faint, :none)
    read_char
  end

  def ask_option(options, prompt: 'Make a selection: ', joiner: ', ')
    options = [options] unless options.is_a? Array
    list = []

    options.each_with_index do |option, index|
      list << ("[#{index + 1}] " + "#{option}".capitalize)
    end

    prompt += (": \n" + list.join(joiner))

    selection = if options.length <= 9
                  ask_digit(prompt)
                else
                  ask_number(prompt)
                end

    option_index = selection - 1

    return BLANK_RESPONSE if option_index.negative? || options[option_index].nil?

    Response.new(options[option_index], index: option_index)
  end
end
