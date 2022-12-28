def sanitize!(text)
  # Remove numeric delimeters
  text.gsub!(/(\d),(\d\d)/, "\\1\\2")

  # Remove percentage cells
  text.gsub!(/\d*\.?\d*%/, '')

  # Collapse multiple spaces
  text.gsub!(/  +/, ' ')

  # Trim leading and tailing whitespace from each line
  text.gsub!(/ +\n/, "\n")
  text.gsub!(/\n +/, "\n")
end

def notate!(text)
  # Mark lines identifying county and precinct names
  text.gsub!(/\n(.*)\n(.*)\nSTATISTICS/, "\nCOUNTY::\\1\nPRECINCT::\\2")

  # Mark lines identifying office and district
  text.gsub!(/\nVote For \d+\n(.*)\n/, "\nOFFICE::\\1\n")

  # Mark lines identifying registered voters and total votes cast per precinct
  text.gsub!("\nRegistered Voters - Total ", "\nREGISTERED::")
  text.gsub!("\nBallots Cast - Total ", "\nCAST::")

  # Sometimes total ballots cast lines get split into multiple lines. Remove line breaks if necessary.
  text.gsub!(/\nCAST::((\d+)(( \d+)*))\n((\d+)(( \d+)*))\n/, "\nCAST::\\1 \\5\n")

  # Mark write-in lines
  text.gsub!("\nWrite-In Totals ", "\nWRITEIN::")

  # Mark candidate lines
  text.gsub!(/\n([A-Z]{3} .+( \d+)+)/, "\nCANDIDATE::\\1")
end

def filter_lines!(text)
  lines = text.split("\n")
  lines.filter! { |line| line =~ /^[A-Z]+::/ }
  text.replace(lines.join("\n"))
end
