#!/usr/bin/env ruby
require_relative './bundle/bundler/setup'

require 'xcodeproj'

def findFolder(project, folder, parent)
 if parent != nil && parent != project
   found =  parent.children.find { |o| o.isa == "PBXGroup" && (o.path == folder || o.name == folder) }
   return found 
  end 
 project.objects.find { |o| o.isa == "PBXGroup" && (o.path == folder || o.name == folder) }
end

def findOrCreateFolder(project, folder, parent)
  if parent==nil
    parent = project
  end
  found = findFolder(project, folder, parent) 
  found == nil ? parent.new_group(folder) : found
end

def find_file_in_directory(parent, full_path)
  parent.files.find {|f| f.path == full_path } 
end

def add_file (project, full_path)
  *folders, filename = full_path.split(/\/+/)

  parent=nil
  first=true
  folders.each { |f| 
    parent = findOrCreateFolder(project, f, parent)
    if first
      parent.path = "Rollout-ios-SDK"
      first=false
    end
  }
  existing_file = find_file_in_directory(parent, full_path)
  if existing_file
    puts "File already exists in project, doing nothing"
    return 1
  end
  file = parent.new_file(full_path)
  puts "adding file #{full_path}"
  ext = File.extname(full_path)
  if [".m"].include? ext
    puts "adding build file for #{full_path}"
    buildFile = project.new(Xcodeproj::Project::PBXBuildFile)
    buildFile.file_ref = file
    buildFile.settings = {COMPILER_FLAGS: "-fobjc-arc"}
    project.targets.each do |t| 
      t.source_build_phase.files << buildFile if t.respond_to?("product_type") and t.product_type == "com.apple.product-type.application"
    end
    return 0
  end
  if [".framework"].include? ext
      puts "adding build file for Framework #{full_path}"
      buildFile = project.new(Xcodeproj::Project::PBXBuildFile)
      buildFile.file_ref = file
      project.targets.each do |t| 
        t.frameworks_build_phase.files << buildFile if  t.respond_to?("product_type") and t.product_type == "com.apple.product-type.application"
        t.build_configurations.each do |c|
          framework_search_path = c.build_settings["FRAMEWORK_SEARCH_PATHS"] || []
          framework_search_path << "$(inherited)"
          framework_search_path << "Rollout-ios-SDK/#{folders.join("/")}"
          c.build_settings.merge!('FRAMEWORK_SEARCH_PATHS' => framework_search_path)
        end
      end
      return 0
  end
  if [".h"].include?  ext
    #Do nothing 
    return 0
  end 
  if [".xib", ".storyboard", ".png", ".plist"].include?  ext
    puts "adding nib file #{full_path} to resources_build_phase"
    buildFile = project.new(Xcodeproj::Project::PBXBuildFile)
    buildFile.file_ref = file
    project.targets.each do |t| 
      t.resources_build_phase.files << buildFile if  t.respond_to?("product_type") and t.product_type == "com.apple.product-type.application"
    end
    return 0
  end
  puts "not sure what to do with beside adding #{full_path}"
  return 0
end

project= Xcodeproj::Project.new(ARGV[0])
project.initialize_from_file

results = [] 
ARGV[1..-1].each do |full_path|
  results.push(add_file(project, full_path))
end
project.save()
exit results.max()

