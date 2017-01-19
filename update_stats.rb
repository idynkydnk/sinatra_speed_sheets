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
    @key = "1lI5GMwYa1ruXugvAERMJVJO4pX5RY69DCJxR4b0zDuI"
    @session = GoogleDrive::Session.from_config("config.json")
    puts @session
    @games_sheet = @session.spreadsheet_by_key(@key).worksheets[0]
    @stats_sheet = @session.spreadsheet_by_key(@key).worksheets[1]
    @team_stats_sheet = @session.spreadsheet_by_key(@key).worksheets[2]
    @top_teams_sheet = @session.spreadsheet_by_key(@key).worksheets[4]
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
    team_stats_wins_and_losses
    
    @team_stats_sheet.save
  end

  def build_top_teams
    top_teams = []
    minimum_number_of_games = 5
    (1..@team_stats_sheet.num_rows).each do |row|
      if @team_stats_sheet[row, 6] >= minimum_number_of_games.to_s
        top_teams << [@team_stats_sheet[row, 5], @team_stats_sheet[row, 6], row]
      end 
    end
    top_teams.sort!.reverse!
    top_teams = top_teams.select.each_with_index { |_, i| i.odd? }
    row = 1
    top_teams.each do |team_row|
      (1..@team_stats_sheet.num_cols).each do |col|
        @top_teams_sheet[row, col] = @team_stats_sheet[team_row[2], col] 
      end
      row += 1
    end
    @top_teams_sheet.save
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

  def team_stats_wins_and_losses
    (1..@team_stats_sheet.num_rows).each do |row|
      player1 = @team_stats_sheet[row, 1]
      player2 = @team_stats_sheet[row, 2]
      wins = 0
      losses = 0
      (1..@games_sheet.num_rows).each do |games_row|
        if (@games_sheet[games_row, 3] == player1 && @games_sheet[games_row, 4] == player2) || (@games_sheet[games_row, 3] == player2 && @games_sheet[games_row, 4] == player1)
          wins += 1 
        end
        if (@games_sheet[games_row, 5] == player1 && @games_sheet[games_row, 6] == player2) || (@games_sheet[games_row, 5] == player2 && @games_sheet[games_row, 6] == player1)
          losses += 1 
        end
      end
      @team_stats_sheet[row, 3] = wins
      @team_stats_sheet[row, 4] = losses
      win_percentage = calc_win_percentage(wins, losses)
      @team_stats_sheet[row, 5] = win_percentage
      @team_stats_sheet[row, 6] = (wins + losses)
    end
  end

  def calc_win_percentage(wins, losses)
    total = wins + losses
    if wins == 0
      return wins
    else
      percentage = wins.to_f / total.to_f
      percentage.round(2)
      return percentage
    end
  end
  

end

season_2017 = BeachSeason.new
season_2017.build_players_database
season_2017.build_team_stats
season_2017.build_top_teams
