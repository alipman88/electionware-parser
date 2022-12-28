# Convert raw text files to CSVs

require 'csv'
require 'set'

require './config'
require './src/csv_helpers'
require './src/office_helpers'
require './src/text_helpers'

# Set up directory structure, if not initialized.
`rm -rf txt csv; cp -R raw txt; mkdir -p csv`

# Pre-process raw text files
Dir.glob('txt/*.txt') do |infile|
  text = File.read(infile)

  sanitize!(text)
  notate!(text)
  filter_lines!(text)

  File.open(infile, 'w') { |file| file.puts(text) }
end

unmatched_offices = Set.new

# Go through processed text files line by line and build CSV
Dir.glob('txt/*.txt') do |infile|
  text = File.read(infile)
  n = count_numeric_columns(text)

  county = infile.delete_prefix('txt/').split(" #{STATE} ")[0]
  outfile = "csv/#{DATE}__#{STATE}__#{ELECTION}__#{county}__precinct.csv".downcase

  CSV.open(outfile, 'w') do |csv|
    csv << DEFAULT_HEADERS

    # county = ''
    precinct = ''
    office = ''
    district = ''

    File.readlines(infile).each(&:strip!).each do |line|
      if line.start_with?('COUNTY::')
        # county = line.delete_prefix('COUNTY::')
      elsif line.start_with?('PRECINCT::')
        precinct = line.delete_prefix('PRECINCT::')
      elsif line.start_with?('OFFICE::')
        row = line.delete_prefix('OFFICE::')
        office, district = extract_office_and_district(row)
        unmatched_offices << row.downcase if office.empty?
      elsif line.start_with?('REGISTERED::')
        row = line.delete_prefix('REGISTERED::')
        csv << [county, precinct, 'Registered Voters', '', '', ''] + [row] + [''] * (n-1)
      elsif line.start_with?('CAST::')
        row = line.delete_prefix('CAST::').split
        csv << [county, precinct, 'Ballots Cast', '', '', ''] + row
      end

      next if office.empty?
      next if line == "CANDIDATE::#{precinct}" # Skip mislabeled precinct lines

      if line.start_with?('CANDIDATE::')
        row = line.delete_prefix('CANDIDATE::').split
        party = row[0]
        candidate = row[1...-n].join(' ')
        votes = row.last(n)
        csv << [county, precinct, office, district, party, candidate] + votes
      elsif line.start_with?('WRITEIN::')
        row = line.delete_prefix('WRITEIN::').split
        votes = row.last(n)
        csv << [county, precinct, office, district, '', 'Write Ins'] + votes
      end
    end
  end
end

`mkdir -p val`
File.open('val/unmatched-offices.txt', 'w') { |file| file.puts(unmatched_offices.sort.join("\n")) }
