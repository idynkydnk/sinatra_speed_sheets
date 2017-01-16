require "google_drive"
require "json"

module Enumerable
  def sort_by_frequency
    histogram = inject(Hash.new(0)) { |hash, x| hash[x] += 1; hash}
    sort_by { |x| [histogram[x], x] }
  end
end

def create_json_arrays(name, col, worksheet)
  (1..worksheet.num_rows).each do |row|
    name << worksheet[row, col]
  end
end

session = GoogleDrive::Session.from_config("config.json")
puts session

worksheet = session.spreadsheet_by_key("1lI5GMwYa1ruXugvAERMJVJO4pX5RY69DCJxR4b0zDuI").worksheets[0]

winners1 = []
winners2 = []
losers1 = []
losers2 = []
locations = []

create_json_arrays(locations, 2, worksheet)
create_json_arrays(winners1, 3, worksheet)
create_json_arrays(winners2, 4, worksheet)
create_json_arrays(losers1, 5, worksheet)
create_json_arrays(losers2, 6, worksheet)
locations = locations.sort_by_frequency
winners1 = winners1.sort_by_frequency
winners2 = winners2.sort_by_frequency
losers1 = losers1.sort_by_frequency
losers2 = losers2.sort_by_frequency
sorted_locations = []
sorted_winners1 = []
sorted_winners2 = []
sorted_losers1 = []
sorted_losers2 = []

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
winners1.reverse_each do |x|
  if sorted_winners1.empty?
    sorted_winners1 << x
  elsif x != sorted_winners1[i] 
    sorted_winners1 << x
    i += 1
  end
end

i = 0
winners2.reverse_each do |x|
  if sorted_winners2.empty?
    sorted_winners2 << x
  elsif x != sorted_winners2[i] 
    sorted_winners2 << x
    i += 1
  end
end

i = 0
losers1.reverse_each do |x|
  if sorted_losers1.empty?
    sorted_losers1 << x
  elsif x != sorted_losers1[i] 
    sorted_losers1 << x
    i += 1
  end
end

i = 0
losers2.reverse_each do |x|
  if sorted_losers2.empty?
    sorted_losers2 << x
  elsif x != sorted_losers2[i] 
    sorted_losers2 << x
    i += 1
  end
end

puts sorted_locations
puts
puts sorted_winners1
puts
puts sorted_winners2
puts
puts sorted_losers1
puts
puts sorted_losers2

#
#         # Yet another way to do so.
#         p ws.rows  #==> [["fuga", ""], ["foo", "bar]]
#
#         # Reloads the worksheet to get changes by other clients.
#         ws.reload

File.open('./data/locations.json', 'w') do |f|
  f.puts sorted_locations.to_json
end

File.open('./data/winners1.json', 'w') do |f|
  f.puts sorted_winners1.to_json
end

File.open('./data/winners2.json', 'w') do |f|
  f.puts sorted_winners2.to_json
end


File.open('./data/losers1.json', 'w') do |f|
  f.puts sorted_losers1.to_json
end

File.open('./data/losers2.json', 'w') do |f|
  f.puts sorted_losers2.to_json
end


worksheet.save
