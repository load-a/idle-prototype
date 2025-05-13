# frozen_string_literal: true

class Screen
  TEXT_HEIGHT = 28
  PROMPT_HEIGHT = 2

  attr_accessor :prompt, :text

  def initialize(text)
    text = [text] unless text.is_a? Array

    self.text = text
  end

  def display
    raise "#{self} is too tall (#{text.length}/#{TEXT_HEIGHT})" if text.length > TEXT_HEIGHT
    system 'clear'
    puts text, prompt
  end
end
