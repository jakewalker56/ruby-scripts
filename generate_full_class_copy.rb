require 'fileutils'
require 'rubygems'
require 'active_support/inflector'

begin 
	if ARGV.count !=4 && ARGV.count !=5
		raise "Usage: generate_full_class_copy.rb <class to copy> <new class name> <copy from directory> <copy to directory>"
	end

	old_class = ARGV[0]
	new_class = ARGV[1]
	from_dir = File.expand_path(ARGV[2])
	to_dir = File.expand_path(ARGV[3])


	if ARGV.count > 4
		replace_hash = eval(ARGV[4])
	else
		replace_hash = {}
	end


	puts "copying class " + old_class + " to class " + new_class + " from " + from_dir + " to " + to_dir + "..."


	#verify existing directory
	if !File.directory?(from_dir)
		raise "ERROR:" + from_dir + " does not exist!"
	end

	#make directory 
	if !File.directory?(to_dir)
		puts "Creating directory " + to_dir + "..."
		FileUtils::mkdir_p to_dir
	end

	#copy and update model, controller, views, helpers
	[
		{ :root => from_dir, :dir => "app/models", :file => ActiveSupport::Inflector.underscore(old_class) + ".rb"},
		{ :root => from_dir, :dir => "app/controllers", :file => ActiveSupport::Inflector.pluralize(ActiveSupport::Inflector.underscore(old_class)) + "_controller.rb"},
		{ :root => from_dir, :dir => "app/helpers", :file => ActiveSupport::Inflector.pluralize(ActiveSupport::Inflector.underscore(old_class)) + "_helper.rb"},
		{ :root => from_dir, :dir => "app/views/" + ActiveSupport::Inflector.pluralize(ActiveSupport::Inflector.underscore(old_class)) }
	].each do |file_hash|
		#first create the dir if it doesn't exist
		if !File.directory?(to_dir + "/" + file_hash[:dir])
			puts "Creating directory " + to_dir + "/" + file_hash[:dir] + "..."
			FileUtils::mkdir_p to_dir + "/" + file_hash[:dir]
		end

		if file_hash.has_key?(:file)
			#if file_name is a file, copy the file
			file_names = [file_hash[:file]]
		else
			#if file_name is a directory, copy all contents
			file_names = Dir.entries(file_hash[:root] + "/" + file_hash[:dir])
			file_names.delete(".")
			file_names.delete("..")
			puts "Copying files from directory: " + file_names.inspect
		end

		file_names.each do |file_name|
			full_from_path = file_hash[:root] + "/" + file_hash[:dir] + "/" + file_name
			full_to_path = to_dir + "/" + file_hash[:dir] + "/" + file_name
			full_to_path = full_to_path.gsub(/#{ActiveSupport::Inflector.underscore(old_class)}/, ActiveSupport::Inflector.underscore(new_class))
			full_to_path = full_to_path.gsub(/#{ActiveSupport::Inflector.pluralize(ActiveSupport::Inflector.underscore(old_class))}/, ActiveSupport::Inflector.pluralize(ActiveSupport::Inflector.underscore(new_class)))
			
			if !File.exists?(full_from_path)
				puts "Skipping " + full_from_path + ", which does not exist"
				next
			end
			
			puts "Copying " + full_from_path + " to " + full_to_path + "..."

			text = File.read(full_from_path)

			new_contents = text.gsub(/#{old_class}/, new_class)
			new_contents = new_contents.gsub(/#{ActiveSupport::Inflector.underscore(old_class)}/, ActiveSupport::Inflector.underscore(new_class))
			new_contents = new_contents.gsub(/#{ActiveSupport::Inflector.pluralize(ActiveSupport::Inflector.underscore(old_class))}/, ActiveSupport::Inflector.pluralize(ActiveSupport::Inflector.underscore(new_class)))
			
			replace_hash.keys.each do |k|
				new_contents = new_contents.gsub(/#{k}/, replace_hash[k])
			end


			to_dirname = File.dirname(full_to_path)
			unless File.directory?(to_dirname)
			  FileUtils.mkdir_p(to_dirname)
			end

			File.open(full_to_path, "w") {|file| file.puts new_contents }
		end
	end


	#TODO: update resource routes?

	#TODO: create migrations?
	puts "SUCCESS!"
rescue Exception => e  
    puts "Found exception!"
    puts e.message  
end