# frozen_string_literal: true

class Prompt
  attr_accessor :text, :input_type

  def initialize(text, input_type = :default)
    self.text = text
    self.input_type = input_type
  end

  def input_symbol
    case input_type
    when :digit
      '# '
    when :number
      '## '
    when :character
      '> '
    when :line
      '>> '
    when :confirm
      '(y/n) '
    when :none
      ''
    else
      '</> '
    end
  end

  def to_s
    "#{text}\n#{input_symbol}"
  end
end
