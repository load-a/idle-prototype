# frozen_string_literal: true

require 'setup'

RSpec.describe Integer do 
  context '#not_positive?' do
    it 'is true if self is less than 1' do 
      expect(-1.not_positive?).to be(true)
    end
  end

  context '#not_negative?' do
    it 'is true if self is less than 1' do 
      expect(1.not_negative?).to be(true)
    end
  end
end
