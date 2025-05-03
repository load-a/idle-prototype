# frozen_string_literal: true

require 'io/console'

class Response
  DEFAULT = '<???>'

  attr_accessor :raw, :default, :index

  def initialize(raw, index: nil)
    self.raw = raw
    self.default = raw.strip.gsub(/\W/, '').empty?
    self.index = index
  end

  def text
    return DEFAULT if default

    raw.strip.downcase.gsub(/\W/, '')
  end

  def character
    return DEFAULT[1] if default

    text[0]
  end
  alias char character

  def number
    text.to_i
  end

  def [](*args)
    text.call('[]', args)
  end

  def number?
    text.to_i.to_s == text
  end

  def default?
    text == DEFAULT
  end
end

module Input
  module_function

  def ask(prompt)
    ARGV.clear
    puts prompt
    Response.new(gets)
  end

  def ask_number(prompt)
    response = ''

    loop do
      puts prompt
      response = Response.new(gets)
      break response if response.number?
    end
  end

  def ask_char(prompt)
    puts prompt
    character = ''

    STDIN.raw do |stdin|
      character = stdin.getc
    end

    # character =~ /\w/ ? Response.new(character) : Response.new('?')
    Response.new(character)
  end

  def ask_option(*options, prompt: 'Make a selection: ')
    list = []

    options.each_with_index do |option, index|
      list << "[#{index + 1}] " + "#{option}".capitalize
    end

    selection = if options.length > 9
      self.ask_number(prompt + ": \n" + list.join(', '))
    else
      self.ask_char(prompt + ": \n" + list.join(', '))
    end

    index = selection.number - 1

    return Response.new('') if selection.number.zero? || options[index].nil?

    Response.new(options[index], index: index)
  end

  def confirm?(prompt)
    ask_char(prompt).character == 'y'
  end
end
