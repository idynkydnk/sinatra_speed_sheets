require "google_drive"
require "json"

session = GoogleDrive::Session.from_config("config.json")
puts session

worksheet = session.spreadsheet_by_key("1lI5GMwYa1ruXugvAERMJVJO4pX5RY69DCJxR4b0zDuI").worksheets[0]

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