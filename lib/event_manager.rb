puts 'Event manager initialized!'

require 'csv'

def clean_zipcode(zip)
    if !zip 
        zip = "00000"
    elsif zip.length < 5
    # if the zip code is less than five digits, add zeros to the front until it becomes five digits
        until zip.length == 5
            zip = "0"+zip
        end
        zip
    elsif zip.length > 5
    # if the zip code is more than five digits, truncate it to the first five digits
        zip = zip[0,5]
    else
        zip
    end
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
