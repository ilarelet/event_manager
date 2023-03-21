puts 'Event manager initialized!'

require 'csv'
require 'google/apis/civicinfo_v2'

def clean_zipcode(zip)
    zip.to_s.rjust(5, "0")[0..4]
end

def repres_by_zipcode(zip)
    civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
    civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
    begin
        representatives = civic_info.representative_info_by_address(
            address: zip,
            levels: 'country',
            roles: ['legislatorUpperBody', 'legislatorLowerBody']
        )
        representatives = representatives.officials
        representative_names = representatives.map(&:name).join(", ")
    rescue
        'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
    end 
end

lines = CSV.open(
    'event_attendees.csv',
    headers: true,
    header_converters: :symbol
)

form_letter = File.read('form_letter.html')

lines.each_with_index do |row| 
    name = row[:first_name]
    zip = clean_zipcode(row[:zipcode])
    representative_names = repres_by_zipcode(zip)
    personal_letter = form_letter.gsub('FIRST_NAME', name)
    personal_letter.gsub!('LEGISLATORS',     representative_names)

    puts personal_letter
end