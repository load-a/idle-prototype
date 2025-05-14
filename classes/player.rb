class Player
  attr_accessor :name, :character, :team, :money

  def initialize(new_name = nil)
    self.name = new_name.nil? ? Input.ask("what is your name?").clean : new_name

    character = CHARACTERS.find { |id, _character| id.to_s.start_with?(self.name.downcase[0]) }&.last || CHARACTERS[:alyssa]

    self.character = character.from_zero
    self.team = Team.new([self.character], "#{name}'s Team", 'Your team')
    self.money = 100
  end
end
