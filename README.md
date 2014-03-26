validate-email
==============

Ruby scripts to validate a list of email addresses.

Usage
=====

./ValidateEmails.rb 
Usage: ValidateEmails COMMAND FILENAME [OPTIONS]

Commands
   domain:  checks each unique domain for MX records
   user:    attempts to check each SMTP RCPT for valid mailbox

Options
    -d, --domain DOMAIN              Domain name for SMTP testing (to match your PTR record)
    -o, --output FILE                Write results to this filename
    -r, --reply-to REPLY             Reply-to MAIL FROM: address for SMTP testing
    -s, --silent                     Quiet Mode
    -h, --help                       help
Examples:
   ./ValidateEmails.rb domain sample.txt -o MXResults.txt
   ./ValidateEmails.rb user sample.txt -d example.net -r webmaster@example.net



Notes
=====

1) Based on: https://github.com/skillnet/validates_email_with_smtp
2) Using Regex from https://github.com/balexand/email_validator
3) Inspired by https://github.com/pash/email_veracity_checker
