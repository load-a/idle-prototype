# frozen_string_literal: true

# style method_name(specific_variables, side, context)

module Specials
  module_function

  def add_roll(source, destination, _context)
    destination.call(source)
  end
end
