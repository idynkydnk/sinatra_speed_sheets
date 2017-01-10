require "google_drive"
require "json"

module Enumerable
  def sort_by_frequency
    histogram = inject(Hash.new(0)) { |hash, x| hash[x] += 1; hash}
    sort_by { |x| [histogram[x], x] }
  end
end
session = GoogleDrive::Session.from_config("config.json")
puts session

ws = session.spreadsheet_by_key("1gvdN0KvpSOz7hV_OKoJKBerwynMKboBnQvHRsbcc4sQ").worksheets[8]

winners = []
losers = []
locations = []

(1..ws.num_rows).each do |row|
  locations << ws[row, 2]
end

(1..ws.num_rows).each do |row|
  (3..4).each do |col|
    winners << ws[row, col]
  end
end

(1..ws.num_rows).each do |row|
  (5..6).each do |col|
    losers << ws[row, col]
  end
end

locations = locations.sort_by_frequency
winners = winners.sort_by_frequency
losers = losers.sort_by_frequency
sorted_locations = []
sorted_winners = []
sorted_losers = []

i = 0
locations.reverse_each do |x|
  if sorted_locations.empty?
    sorted_locations << x
  elsif x != sorted_locations[i] 
    sorted_locations << x
    i += 1
  end
end

i = 0
winners.reverse_each do |x|
  if sorted_winners.empty?
    sorted_winners << x
  elsif x != sorted_winners[i] 
    sorted_winners << x
    i += 1
  end
end

i = 0
losers.reverse_each do |x|
  if sorted_losers.empty?
    sorted_losers << x
  elsif x != sorted_losers[i] 
    sorted_losers << x
    i += 1
  end
end

puts sorted_locations
puts
puts sorted_winners
puts
puts sorted_losers
puts

#
#         # Yet another way to do so.
#         p ws.rows  #==> [["fuga", ""], ["foo", "bar]]
#
#         # Reloads the worksheet to get changes by other clients.
#         ws.reload
puts ws

File.open('./data/locations.json', 'w') do |f|
  f.puts sorted_locations.to_json
end

File.open('./data/winners.json', 'w') do |f|
  f.puts sorted_winners.to_json
end

File.open('./data/losers.json', 'w') do |f|
  f.puts sorted_losers.to_json
end

puts ws.num_rows
ws.save
