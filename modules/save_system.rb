# frozen_string_literal: true

module SaveSystem
  module_function

  def save(game)
    save_file = File.read('game_data/save_data.json')

    if !save_file.empty?
      return unless Input.confirm?("SAVE the game? (This will overwrite your save file.)")
    end

    IO.write('game_data/save_data.json', JSON.pretty_generate(game.serialize))

    'Saved Game'
  end

  def load(game)
    save_file = File.read('game_data/save_data.json')

    if save_file.empty?
      puts "No save data." 
      Input.ask_keypress
      return
    end

    return unless Input.confirm?("LOAD save data? (This will erase the current game.)")

    data = JSON.parse(save_file)
    game.deserialize(data)

    'Loaded game'
  end
end
