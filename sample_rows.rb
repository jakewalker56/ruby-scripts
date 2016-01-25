if ARGV.count < 3
  raise "Usage: sample_lines.rb input_file_name output_file_name sample_rate"
end

output = File.open(ARGV[1], 'w')

first = true
File.foreach(ARGV[0]) {|line| 
  if Random.rand(1.0) < ARGV[2].to_f || first
    output.write(line)
    first = false
  end
}

output.close

