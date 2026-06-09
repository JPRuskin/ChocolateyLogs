$script:MultilinePattern = -join @(
    "(?m)"  # Multiline
    "^"  # We want to match from the start of a log line
    "(?<Timestamp>\d{4}-\d{2}-\d{2}\W+\d{2}:\d{2}:\d{2},\d{3})\W+"  # There should be a timestamp, in a known format
    "(?<ProcessID>\d+)\W+"  # Then a string of digits (processId)
    "\[(?<Stream>INFO|DEBUG|WARN|ERROR) ?\]"  # Then whichever stream the command was on
    " - "  # a separator
    "(?<Message>(?:.|\n)*?)\n"  # and then a message that can span multiple lines
    "(?=^\d{4}-\d{2}-\d{2}\W+\d{2}:\d{2}:\d{2},\d{3}\W+\d+\W+\[|\Z)"  # Finally, we should see the next log, or the end of the file
)