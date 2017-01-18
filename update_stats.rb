require "google_drive"
require "json"

module Enumerable
  def sort_by_frequency
    histogram = inject(Hash.new(0)) { |hash, x| hash[x] += 1; hash}
    sort_by { |x| [histogram[x], x] }
  end
end

class BeachSeason
  attr_accessor :players

  def initialize
    @session = GoogleDrive::Session.from_config("config.json")
    puts @session
    @games_sheet = @session.spreadsheet_by_key("1lI5GMwYa1ruXugvAERMJVJO4pX5RY69DCJxR4b0zDuI").worksheets[0]
    @stats_sheet = @session.spreadsheet_by_key("1lI5GMwYa1ruXugvAERMJVJO4pX5RY69DCJxR4b0zDuI").worksheets[1]
    @team_stats_sheet = @session.spreadsheet_by_key("1lI5GMwYa1ruXugvAERMJVJO4pX5RY69DCJxR4b0zDuI").worksheets[2]
    @players = []
  end

  def remove_duplicates(duplicates)
    i = 0
    removed = []
    duplicates.reverse_each do |x|
      if removed.empty?
        removed << x
      elsif x != removed[i] 
        removed << x
        i += 1
      end
    end
    return removed
  end

  def build_players_database
    (1..@games_sheet.num_rows).each do |row|
      (3..@games_sheet.num_cols).each do |col|
          @players << @games_sheet[row,col] 
      end
    end
    @players = @players.sort_by_frequency
    @players = remove_duplicates(@players)
  end

  def build_team_stats
    team_stats_col_1
    team_stats_col_2
    team_stats_wins
    
    @team_stats_sheet.save
  end

  private

  def team_stats_col_1
    row = 1
    @players.each do |player|
      @players.length.times do
        @team_stats_sheet[row, 1] = player
        row += 1
      end
    end
  end

  def team_stats_col_2
    row = 1
    @players.length.times do
      @players.each do |player2|
        @team_stats_sheet[row, 2] = player2
        row += 1
      end
    end
  end

  def team_stats_wins
    
  end

end
season_2017 = BeachSeason.new
season_2017.build_players_database
season_2017.build_team_stats
