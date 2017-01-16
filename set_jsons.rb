require "google_drive"
require "json"

session = GoogleDrive::Session.from_config("config.json")
puts session

worksheet = session.spreadsheet_by_key("1lI5GMwYa1ruXugvAERMJVJO4pX5RY69DCJxR4b0zDuI").worksheets[0]

module Enumerable
  def sort_by_frequency
    histogram = inject(Hash.new(0)) { |hash, x| hash[x] += 1; hash}
    sort_by { |x| [histogram[x], x] }
  end
end

def sort_arrays(name) 
  i = 0
  sorted_name = []
  name.reverse_each do |x|
    if sorted_name.empty?
      sorted_name << x
    elsif x != sorted_name[i] 
      sorted_name << x
      i += 1
    end
  end
  return sorted_name
end

def sort_arrays_by_frequency(name)
  name = name.sort_by_frequency
end

def create_json_arrays(name, col, worksheet)
  (1..worksheet.num_rows).each do |row|
    name << worksheet[row, col]
  end
end

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

locations = sort_arrays_by_frequency(locations)
winners1 = sort_arrays_by_frequency(winners1)
winners2 = sort_arrays_by_frequency(winners2)
losers1 = sort_arrays_by_frequency(losers1)
losers2 = sort_arrays_by_frequency(losers2)

locations = sort_arrays(locations)
winners1 = sort_arrays(winners1)
winners2 = sort_arrays(winners2)
losers1 = sort_arrays(losers1)
losers2 = sort_arrays(losers2)

#         # Yet another way to do so.
#         p ws.rows  #==> [["fuga", ""], ["foo", "bar]]
#
#         # Reloads the worksheet to get changes by other clients.
#         ws.reload

File.open('./data/locations.json', 'w') do |f|
  f.puts locations.to_json
end

File.open('./data/winners1.json', 'w') do |f|
  f.puts winners1.to_json
end

File.open('./data/winners2.json', 'w') do |f|
  f.puts winners2.to_json
end


File.open('./data/losers1.json', 'w') do |f|
  f.puts losers1.to_json
end

File.open('./data/losers2.json', 'w') do |f|
  f.puts losers2.to_json
end

worksheet.save
