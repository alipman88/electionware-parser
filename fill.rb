require 'csv'

# headers
OFFICE = 2
DISTRICT = 3
CANDIDATE = 5

district_map = {}

# Scan through CSVs to make a hash of district numbers, keyed by candidate name & office.
Dir.glob('csv/*.csv') do |infile|
  csv = CSV.open(infile)

  csv.each do |row|
    office = row[OFFICE]
    district = row[DISTRICT]
    candidate = row[CANDIDATE]
    next if district.empty? || district == 'undetermined' || candidate == 'Write Ins'

    key = [office, candidate]
    district_map[key] = district
  end
end

# Fill in any undetermined district values based on other rows.
# TODO: log any auto-filled candidate/office districts for spot-checking purposes.
Dir.glob('csv/*.csv') do |infile|
  out = []
  district = 'undetermined'

  CSV.open(infile).each do |row|
    unless row[DISTRICT] == 'undetermined'
      district = row[DISTRICT]
      out << row
      next
    end

    office = row[OFFICE]
    candidate = row[CANDIDATE]

    if candidate == 'Write Ins'
      row[DISTRICT] = district
    else
      key = [office, candidate]

      # Ask for any missing districts that can't be filled in based on other rows.
      if district_map[key].nil?
        print "What #{office} district did #{candidate} run for? > "
        district_map[key] = gets.chomp
      end

      row[DISTRICT] = district_map[key]
      district = district_map[key]
    end

    out << row
  end

  CSV.open(infile, 'w') do |csv|
    out.each do |row|
      csv << row
    end
  end
end
