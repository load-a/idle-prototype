# frozen_string_literal: true

module SaveSystem
  module_function

  def save(game)
    IO.write('game_data/save_data.json', JSON.pretty_generate(game.serialize))
  end

  def load(game)
    data = JSON.parse(File.read('game_data/save_data.json'))
    game.deserialize(data)
  end

  def delete_file; end
end
