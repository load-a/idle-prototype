# frozen_string_literal: true

require 'setup'

RSpec.describe Output do
  context '.new_screen' do
    it 'Clears Output and prints supplied text to screen' do
      # I do not know how to test for `system 'clear'`
      expect { Output.new_screen('Hello, world') }.to output("Hello, world\n").to_stdout
    end
  end
end
