## Overview

This codebase parses PDFs of election results generated by Electionware.

First, PDFs are placed in the `pdf` directory. Raw text is extracted from each PDF and placed in the
`raw` directory. The raw text files are processed into an intermediary format, and placed in the
`txt` directory. Finally, the intermediary text files are processed into CSVs, placed in the `csv`
directory.

## Requirements

- Ruby 2.7+
- Bash (or some compatible shell)
- Google Chrome (recommended, other PDF readers may work)
- TextEdit (or some other text editor)

## Instructions

*CSV Generation*

1. Copy the contents of `config.rb.example` into `config.rb` (`cp config.rb.example config.rb`).
   Adjust the `DATE`, `ELECTION` and `STATE` settings in `config.rb` based on the PDFs being
   processed. (As these settings are used to format CSV file names, election results for only a
   single state and election date may be processed at once.)
2. Create a pdf directory (`mkdir pdf`).
3. Place the PDFs you wish to convert in the pdf directory. Note the codebase assumes PDF filenames
   beginning with county and state abbreviation, e.g. `Allegheny PA`.
4. Run `ruby copy.rb` – this will open the PDFs one by one, alongside an accompanying empty text
   file. From your PDF reader, select all and copy the PDF content to your clipboard.
   Paste the content into the empty text file. Press enter to continue to the next PDF.<br>
   _TODO: find an automated means of extracting text from PDFs, e.g. Poppler's pdftotext utility._
5. Run `ruby process.rb` – this will process the raw text files into an intermediary format, and
   then process the intermediary files into CSVs.
6. Check the `val/unmatched-offices.txt` file – this contains any unmatched office names that were
   not included in the CSV. If any desired offices (Governor, US Senate, US House, State Senate,
   State House, etc.) are listed as unmatched, adjust `src/office_helpers.rb` as necessary. Re-run
   the `process.rb` script until satisfied.
7. Check the parsed CSVs in the csv directory, and adjust the headers as necessary. In addition to
   raw vote totals, many counties will include totals for election day votes, early/mail/absentee
   votes, provisional ballots, etc. As it's challenging to reliably parse headers from the PDFs, the
   default headers contained in `config.rb` are prepended to all CSVs.

*CSV Linting and Validation*

1. Run `ruby lint.rb` to standardize candidate names - the script will interactively
   suggest text substitutions (correcting capitalization, punctuation, etc.) for approval.
2. Run `ruby fill.rb` to fill in missing district info, as some counties do not specify
   district numbers - the script will attempt to fill in missing district numbers by referencing
   other CSVs, and interactively prompt for district numbers when unable to fill automatically.
3. Run `ruby validate.rb` to check the CSVs for common errors (e.g. uneven row lengths and rows with
   undetermined district numbers).
4. Check the candidate and precinct names in the `val/candidates.txt` and `val/precincts.txt` files.
   Use your text editor's find-and-replace function to make any final adjustments to capitalization,
   puncuation, etc. as desired.
