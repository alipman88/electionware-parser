# Check for common errors, such as uneven row lengths or missing districts.
#
# TODO:
# - Warn if a candidate appears to be running for multiple offices/districts or
#   on multiple party lines.
# - Produce an easy-to-scan text file with rows for all candidates and columns
#   for party, office and district.

# header numbers
PRECINCT = 1
OFFICE = 2
DISTRICT = 3
CANDIDATE = 5

# offices requiring districts
DISTRICT_REQUIRED = [
  'U.S. House',
  'State Senate',
  'State House',
  'State Assembly',
]

require 'csv'
require 'set'

uneven_csvs = {}
undetermined_districts = Set.new

candidates = Set.new
precincts = Set.new

Dir.glob('csv/*.csv') do |infile|
  csv = CSV.open(infile)
  header_length = csv.first.length

  csv.each do |row|
    candidates << row[CANDIDATE]
    precincts << row[PRECINCT]

    # Flag missing required district values as undetermined.
    if DISTRICT_REQUIRED.include?(row[OFFICE]) && row[DISTRICT].empty?
      row[DISTRICT] = 'undetermined'
    end

    undetermined_districts << infile if row[DISTRICT] == 'undetermined'

    if header_length != row.length
      uneven_csvs[infile] ||= []
      uneven_csvs[infile] << csv.lineno
    end
  end
end

`mkdir -p val`
File.open('val/candidates.txt', 'w') { |file| file.puts(candidates.to_a.sort.join("\n")) }
File.open('val/precincts.txt', 'w') { |file| file.puts(precincts.to_a.sort.join("\n")) }

if uneven_csvs.any?
  puts ''
  puts 'CSVs WITH UNEVEN ROWS:'

  uneven_csvs.each do |filename, uneven_row_numbers|
    puts '----------------------'
    puts filename
    puts uneven_row_numbers.first(100)

    if uneven_row_numbers.size > 100
      puts "... and #{uneven_row_numbers.size - 100} more"
    end
  end
end

if undetermined_districts.any?
  puts ''
  puts 'CSVs WITH UNDETERMINED DISTRICTS:'
  puts '---------------------------------'

  undetermined_districts.each do |filename|
    puts filename
  end
end
