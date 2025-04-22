# frozen_string_literal: true

class Response
  attr_accessor :raw
  def initialize(raw)
    self.raw = raw
  end

  def text
    raw.strip.downcase
  end

  def character
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
end

module Input
  module_function

  def ask(prompt)
    puts prompt
    Response.new(gets)
  end

  def ask_number(prompt, digits)
    loop do
      puts prompt
      break if Response.new(gets).number?
    end
  end
end
