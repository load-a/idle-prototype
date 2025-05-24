# frozen_string_literal: true

require 'setup'

RSpec.describe String do
  context '#fill' do 
    it 'appends the specified character to itself until it reaches the specified length' do
      expect('abc'.fill('.', 5)).to match('abc..')
    end

    it 'does not change self if length specified is less than its own length' do
      expect('abc'.fill('.')).to match('abc')
      expect('def'.fill('-', -10)).to match('def')
    end

    it 'only uses the first character in character argument' do
      expect('Hello '.fill('world', 10)).to match('Hello wwww')
    end
  end

  context '#integer?' do 
    it 'is true if self is the literal representation of a decimal Integer' do
      expect('256'.integer?).to be(true)
      expect('-128'.integer?).to be(true)
    end

    it 'is false if there are any leading zeros in self' do
      expect('00100'.integer?).to be(false)
    end

    it 'is false if the self does not represent an Integer' do
      expect('100.1'.integer?).to be(false)
    end

    it 'is false if self does not represent a decimal number' do
      expect('0xfa'.integer?).to be(false)
      expect('0b100110'.integer?).to be(false)
      expect('080'.integer?).to be(false)
    end
  end
end
