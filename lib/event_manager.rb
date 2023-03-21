puts 'Event manager initialized!'

require 'csv'
require 'google/apis/civicinfo_v2'

civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

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
    begin
        representatives = civic_info.representative_info_by_address(
            address: zip,
            levels: 'country',
            roles: ['legislatorUpperBody', 'legislatorLowerBody']
        )
        representatives = representatives.officials
        representative_names = representatives.map(&:name)
    rescue
        'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
    end 

    puts "#{name}, #{zip}: #{representative_names}"
end