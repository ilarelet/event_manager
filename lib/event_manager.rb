puts 'Event manager initialized!'

require 'csv'

def clean_zipcode(zip)
    zip.to_s.rjust(5, "0")[0..4]
end

lines = CSV.open(
    'event_attendees.csv',
    headers: true,
    header_converters: :symbol
)

lines.each_with_index do |row| 
    name = row[:first_name]
    zip = clean_zipcode(row[:zipcode])

    puts "#{name}, #{zip}"
end
