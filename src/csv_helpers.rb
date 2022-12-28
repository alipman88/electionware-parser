# Determine the number of numeric cells contained in each row.
# Numeric cells represent total votes, election day votes, early votes, etc.
def count_numeric_columns(text)
  hash = {}

  text.split("\n").each do |line|
    next unless line.start_with?('CAST::') ||
                line.start_with?('WRITEIN::') ||
                line.start_with?('CANDIDATE::')

    cells = line.split(' ').reverse

    count = 0

    cells.each do |cell|
      if cell =~ /\d+/
        count += 1
      else
        break
      end
    end

    hash[count] ||= 0
    hash[count] += 1
  end

  hash.max_by { |_, v| v }.first
end
