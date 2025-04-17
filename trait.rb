# frozen_string_literal: true

class Trait
  attr_accessor :name, :id, :description, :use_text, :components
  def initialize(name, id, description)
    self.id = id
    self.name = name
    self.description = description
    self.use_text = use_text
    self.components = components
  end

  def use(source, type, encounter)
    Specials.send(id, source, type, encounter)
  end

  def to_s
    '%-16s -- %s' % [name, description]
  end
end
