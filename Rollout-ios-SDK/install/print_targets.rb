#!/usr/bin/env ruby
require_relative './bundle/bundler/setup'

require 'xcodeproj'
project= Xcodeproj::Project.new(ARGV[0])
project.initialize_from_file

project.targets.each do |source_target| 
  if source_target.respond_to?("product_type")
    puts "#{source_target.name} - #{source_target.product_type}"
  else
    puts "#{source_target.name} - !!! uknown"
  end
end
exit



