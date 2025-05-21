# frozen_string_literal: true

module TeamSerializer
  def serialize
    serial_hash = {
      'members' => []
    }

    members.each_with_index { |member, _index| serial_hash['members'] << member.serialize }
    serial_hash['name'] = name
    serial_hash['description'] = description

    serial_hash
  end

  def deserialize(serial_hash)
    members.clear

    serial_hash['members'].each do |member_hash|
      members << CHARACTERS[member_hash['id'].to_sym].deserialize(member_hash)
    end

    members.each(&:set_schedule)

    self.name = serial_hash['name']
    self.description = serial_hash['description']

    self
  end
end
