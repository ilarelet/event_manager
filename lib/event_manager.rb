puts 'Event manager initialized!'

require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

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
    rescue
        'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
    end 
end

lines = CSV.open(
    'event_attendees.csv',
    headers: true,
    header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_letter = ERB.new template_letter
Dir.mkdir('Personal letters') unless Dir.exists?('Personal letters')


lines.each_with_index do |row| 
    id = row[0]
    name = row[:first_name]
    zip = clean_zipcode(row[:zipcode])
    representative_names = repres_by_zipcode(zip)
    personal_letter = erb_letter.result(binding)
    output = File.open("Personal letters/#{id} letter.html",'w')

    output.puts personal_letter
    output.close
end