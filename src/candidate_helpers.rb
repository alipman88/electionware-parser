def titleize(original)
  original.split.map(&:capitalize).join(' ')
end

def lint(original)
  return '' if original.empty?

  suggested = original

  # Prefer only listing first candidate for joint tickets (e.g. Gov & Lt. Gov.)
  suggested = suggested.split('&').first
  suggested = suggested.split('/').first
  suggested = suggested.split(/ and /i).first
  suggested.strip!

  # Capitalize each word if uppercase
  suggested = titleize(suggested) if suggested == suggested.upcase
  
  # Add period after initial if not present
  suggested = suggested.gsub(/ ([A-Z]) /, ' \1. ')

  return suggested
end
