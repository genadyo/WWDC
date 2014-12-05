#!/usr/bin/env ruby
require_relative './bundle/bundler/setup'

require 'xcodeproj'

project= Xcodeproj::Project.new(ARGV[0])
project.initialize_from_file

title = ARGV[1]
content = ARGV[2]
project.targets.each do |source_target| 
  if source_target.respond_to?("product_type") and source_target.product_type == "com.apple.product-type.application"
    source_build_phase = source_target.source_build_phase
    build_phases = source_target.build_phases

    existing_build_phase = build_phases.find { |b| b.respond_to?(:name) and b.name == title} 
    build_phases.delete(existing_build_phase) unless existing_build_phase.nil?

    script_build_phase = project.new(Xcodeproj::Project::Object::PBXShellScriptBuildPhase)
    script_build_phase.name = title
    script_build_phase.shell_script = content
    build_phases.insert(0, script_build_phase)  
  end
end
project.save()
exit



