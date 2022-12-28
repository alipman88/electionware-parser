# Extract office and district
# The variability in formatting requires a somewhat extensive rule-set. Update as necessary.
# TODO: Come up with friendlier format. Maybe a YAML file.
def extract_office_and_district(string)
  case string.downcase

  # Governor
  when 'governor',
       'governor and lieutenant governor',
       'governor/lieutenant governor'
    return ['Governor', '']

  # US Senate
  when 'united states senator'
    return ['U.S. Senate', '']

  # US House
  when /^representative in congress (\d+)(st|nd|rd|th) (congressional|cong\.) (district|dist\.)$/,
       /^representative in congress (\d+)(st|nd|rd|th) district$/,
       /^representative in congress district (\d+)/,
       /^u\.?s\.? congress district (\d+) (\d+)(st|nd|rd|th) district$/,
       'representative in congress'
    district = string.scan(/\d+/).first
    return ['U.S. House', district || 'undetermined']

  # State Senate
  when /^senator in the general assembly (\d+)(st|nd|rd|th) (senatorial|sen\.) (district|dist\.)$/,
       /^senator in the general assembly (\d+)(st|nd|rd|th) (district|dist\.)$/,
       /^senator in the general assembly (district|dist\.) (\d+)$/,
       'senator in the general assembly'
    district = string.scan(/\d+/).first
    return ['State Senate', district || 'undetermined']

  # General Assembly
  when /^representative in the general assembly (\d+)(st|nd|rd|th) (district|dist\.)$/,
       /^representative in the general assembly (\d+)(st|nd|rd|th) (legislative|leg\.) (district|dist\.)$/,
       /^representative in the general assembly district (\d+)$/,
       'representative in the general assembly'
    district = string.scan(/\d+/).first
    return ['General Assembly', district || 'undetermined']
  else
    return ['', '']
  end
end
