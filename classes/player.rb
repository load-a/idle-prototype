class Player
  attr_accessor :name, :character, :team, :money

  def initialize(new_name = nil)
    self.name = new_name.nil? ? Input.ask('what is your name?').clean : new_name

    character = CHARACTERS.find do |id, _character|
      id.to_s.start_with?(name.downcase[0])
    end&.last || CHARACTERS[:alyssa]

    self.character = character.from_zero
    self.team = Team.new([self.character], "#{name}'s Team", 'Your team')
    self.money = 100
  end

  def serialize
    {
      name: name,
      money: money,
      team: team.serialize,
      character: character.id
    }
  end

  def deserialize(serial_hash)
    self.name = serial_hash['name']
    self.money = serial_hash['money']
    self.team = team.deserialize(serial_hash['team'])
    self.character = team.leader
    self
  end
end
