# Open PDF files via Chrome for easy copy and pasting into text files.

require './config'

# Set up directory structure, if not initialized.
`mkdir -p pdf raw`

puts 'From Chrome, select all and copy the PDF content to your clipboard.'
puts 'Paste into the empty text file and save.'
puts 'Close both files and press enter to continue.'
puts ''

Dir.glob('pdf/*.pdf') do |infile|
  outfile = "raw/#{infile.delete_prefix('pdf/').delete_suffix('.pdf')}.txt"
  `touch "#{outfile}"`
  `open -a "#{TEXT_EDITOR}" "#{outfile}"`
  `open -a "#{PDF_READER}" "#{infile}"`
  print infile
  gets
end
