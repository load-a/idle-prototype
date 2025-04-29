class Player
  attr_accessor :name, :character, :team, :money

  def initialize(_name)
    self.name = Response.new('alyssa').text # Input.ask("what is your name?").text

    character = CHARACTERS.find { |id, _character| id.to_s.start_with?(name[0]) }&.last || CHARACTERS[:alyssa]

    self.character = character #.from_zero
    self.team = Team.new([self.character], "#{name}'s Team", 'Your team')
    self.money = 100
  end
end
