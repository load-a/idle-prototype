class Player
  attr_accessor :name, :character, :team, :money

  def initialize(name)
    self.name = name # Input.ask("what is your name?").text

    character = CHARACTERS.find { |id, _character| id.to_s.start_with?(name[0]) }&.last || CHARACTERS[:alyssa]

    self.character = character #.from_zero
    self.team = Team.new([self.character], "#{name}'s Team", 'Your team')
    self.money = 100
  end
end
