require 'rubygems'
require 'nokogiri'
require 'open-uri'

if ARGV.count < 2 
  raise "Usage: remove_whitespace.rb input_file_name output_file_name"
end

output = File.open(ARGV[1], 'w')

File.foreach(ARGV[0]) {|line| 
  out_line = line.gsub(/\s+/, "")
  output.write(out_line)
  output.write("\n")
}

output.close

