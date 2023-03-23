puts 'Event manager initialized!'

require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'time'
require 'date'

def clean_zipcode(zip)
    zip.to_s.rjust(5, "0")[0..4]
end

def clean_phone(phone)
    phone.to_s.gsub!(/[-(). ]/, "")
    if phone.length == 10 or (phone.length == 11 and phone[0] == "1")
        phone.rjust(11, "1")
    else
        "-"
    end
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

def create_letter(id, letter)    
    Dir.mkdir('Personal letters') unless Dir.exists?('Personal letters')
    output = File.open("Personal letters/#{id} letter.html",'w')
    output.puts letter
    output.close
end

lines = CSV.open(
    'event_attendees.csv',
    headers: true,
    header_converters: :symbol
)



template_letter = File.read('form_letter.erb')
erb_letter = ERB.new template_letter
hours = Hash.new(0)
weekdays = Hash.new(0)
max_hour_count = 0
max_wday_count = 0

lines.each_with_index do |row| 
    id = row[0]
    name = row[:first_name]
    phone = clean_phone(row[:homephone])
    zip = clean_zipcode(row[:zipcode])
    representative_names = repres_by_zipcode(zip)
    personal_letter = erb_letter.result(binding)
    #Output into the file
    create_letter(id, personal_letter)

    #Parsing the date and time of the registration
    reg_date = Time.strptime(row[:regdate], "%m/%d/%Y %k:%M")
    #Determining the most common hour to register
    hours[reg_date.hour] += 1
    max_hour_count = hours[reg_date.hour] if hours[reg_date.hour] > max_hour_count
    #Determining the most common weekday to register 
    weekdays[reg_date.wday] += 1
    max_wday_count = weekdays[reg_date.wday] if weekdays[reg_date.wday] > max_wday_count 
end
most_common_hours = hours.filter { |hour, count| count == max_hour_count}.keys
most_common_weekdays = weekdays.filter { |wday, count| count == max_wday_count}.keys
#converting the weekday numbers to the weekday names
most_common_weekdays.map! {|wday_num| Date::DAYNAMES[wday_num]}

puts "Most popular hour#{
    if most_common_hours.length == 1
        ' is'
    else
        's are'
    end}: #{most_common_hours.join(', ')}"
puts "Most popular weekday#{
    if most_common_weekdays.length == 1
        ' is'
    else
        's are'
    end}: #{most_common_weekdays.join(', ')}"