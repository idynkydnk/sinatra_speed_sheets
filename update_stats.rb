require "google_drive"
require "json"

class BeachSeason
  attr_accessor :players

  def initialize
    session = GoogleDrive::Session.from_config("config.json")
    puts session
    @games_sheet = session.spreadsheet_by_key("1lI5GMwYa1ruXugvAERMJVJO4pX5RY69DCJxR4b0zDuI").worksheets[0]
    @players = []
  end

  def build_players_database
    (1..@games_sheet.num_rows).each do |row|
      (3..@games_sheet.num_cols).each do |col|
        if !@players.include?(@games_sheet[row,col])
          @players << @games_sheet[row,col] 
        end
      end
    end
  end

end
season_2017 = BeachSeason.new
season_2017.build_players_database
puts season_2017.players
