require 'csv'
require 'set'

require './src/candidate_helpers'

`mkdir -p csv`

# TODO: only replace values in a specified column, and only if office and district match
def replace_all(original, suggested)
  Dir.glob('csv/*.csv') do |infile|
    text = File.read(infile).gsub(",#{original},", ",#{suggested},")
    File.open(infile, 'w') { |file| file.puts(text) }
  end
end

# Build list of candidate names
candidates = Set.new
Dir.glob('csv/*.csv') do |infile|
  CSV.open(infile, headers: true).each do |row|
    candidates << row['candidate'] unless row['candidate'].empty?
  end
end

linted_candidates = candidates.map { |candidate| lint(candidate) }.uniq

# Sort linted candidate names to prefer non-automatized capitazliation patterns like
# "Georgia O'Keefe" over "Georgia O'keefe", "John McCain" over "John Mccain",
# "Vincent van Gogh" over "Vincent Van Gogh", etc.
linted_candidates.sort_by! do |candidate|
  [-candidate.length, candidate == titleize(candidate) ? 1 : 0, candidate]
end

verified_replacements = {}

puts "---------------------------------------------------------------------"
puts "Type y or n and press enter to proceed. (Blank replies count as yes.)"
puts "---------------------------------------------------------------------"

candidates.sort.each do |original|

  verified_replacement = verified_replacements[original.downcase]

  next if original == verified_replacement

  if verified_replacement
    puts "replace \"#{original}\" with \"#{verified_replacement}\" > y [auto]"
    replace_all(original, verified_replacement)
    next
  end

  suggested = linted_candidates.find { |linted| linted.upcase.include?(lint(original).upcase) }
  suggested ||= lint(original)

  next if original == suggested

  print "replace \"#{original}\" with \"#{suggested}\" > "

  response = gets.chomp

  if response.empty? || response.downcase.start_with?('y')
    replace_all(original, suggested)
    verified_replacements[original.downcase] = suggested
  end
end
