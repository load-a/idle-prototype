require 'setup'

RSpec.describe 'SCREEN_WIDTH' do
  it 'always equals 120' do
    expect(SCREEN_WIDTH).to eq 120
  end
end

RSpec.describe 'SPEED_MULTIPLIER' do
  it 'is a hash' do 
    expect(SPEED_MULTIPLIER).to be_a(Hash)
  end
end

RSpec.describe 'NO_ITEM' do
  it 'is an Item with default attributes' do
    expect(NO_ITEM.name).to match('None')
    expect(NO_ITEM.id).to be(:none)
    expect(NO_ITEM.cost).to eq(0)
    expect(NO_ITEM.description).to match('No Item')
  end
end

RSpec.describe 'BLANK_RESPONSE' do
  it 'is a Response with empty attributes' do
    expect(BLANK_RESPONSE.line.empty?).to be(true)
    expect(BLANK_RESPONSE.index).to eq(0)
  end
end
