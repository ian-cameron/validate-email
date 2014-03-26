#!/usr/bin/env ruby
require 'lib/email_check.rb'
require 'optparse'

options = {}

opt_parser = OptionParser.new do |opt|
  opt.banner = "Usage: ValidateEmails COMMAND FILENAME [OPTIONS]"
  opt.separator ""
  opt.separator "Commands"
  opt.separator "   domain:  checks each unique domain for MX records"
  opt.separator "   user:    attempts to check each SMTP RCPT for valid mailbox"
  opt.separator ""
  opt.separator "Options" 
  opt.on("-d", "--domain DOMAIN", "Domain name for SMTP testing (to match your PTR record)") do |domain|
    options[:domain] = domain
  end

  opt.on("-o", "--output FILE", "Write results to this filename") do |file|
    options[:outfile] = file
  end
    
  opt.on("-r", "--reply-to REPLY", "Reply-to MAIL FROM: address for SMTP testing") do |reply|
    options[:reply] = reply
  end  

  opt.on("-s", "--silent", "Quiet Mode") do 
    options[:silent] = true
  end
  
  opt.on("-h", "--help", "help") do
    puts opt_parser
  end
  opt.separator "Examples:"
  opt.separator "   ./ValidateEmails.rb domain sample.txt -o MXResults.txt"
  opt.separator "   ./ValidateEmails.rb user sample.txt -d example.net -r webmaster@example.net"  

  
end

opt_parser.parse!

if !ARGV[1]
  puts opt_parser 
  exit
end

if options[:outfile] && options[:silent]
  puts "You specified silent output but no output file.  Exiting."
  exit
end

lines = []
rejected = 0
outfile = File.open(options[:outfile], "a") if options[:outfile]
reply = options[:reply] || "no-reply@example.com"
domain = options[:domain] || "exmaple.com"

File.readlines(ARGV[1]).each_with_index do |value, i|
  if value =~ /\A\s*(["a-z0-9+._"]{1,64})@((?:[-a-z0-9]+\.)+[a-z]{2,})\s*\z/i
    lines << value
  else
    puts "#{value.chomp} on line #{i} is not a valid email address."
    rejected += 1
  end
end
puts "Loaded #{lines.count} lines.  Rejected #{rejected} badly formed addresses."

case ARGV[0]
  # Check for valid email domains
  when "domain"
    domains = []
    lines.each do |l|
      domains << l.split("@")[1]
    end
    lines = domains.map{|i| i.downcase}.uniq
    puts "Checking #{lines.size} Unique Domains"
    lines.each do |domain|
      result = EmailCheck.get_mail_server(domain.chomp)
      puts "#{domain.chomp}, #{result || 'NO MX RECORD FOUND'}" unless options[:silent]
      outfile << "#{domain.chomp}, #{result || 'NO MX RECORD FOUND'}\n" if outfile
    end
  # Check for valid email recipients
  when "user"
    puts "Checking #{lines.size} Users"
    lines.each do |address|
      result = EmailCheck.run(address.chomp, reply, domain)
      puts "#{address.chomp}, #{result.status}"
      outfile.write("#{address.chomp}, #{result.status}\n") if outfile
    end
  else
    puts opt_parser
end

outfile.close if outfile
puts "Saved to #{options[:outfile]}" if outfile


