#!/usr/bin/env ruby

require "json"

$errors_dictionary = {
  $error_no_file_argument_given = 1 => "Usage: #{$0} <gzipped json structure>",
  $error_could_not_unzip_file = 2 => "Couldn't unzip input file",
  $error_could_not_parse_json = 3 => "Couldn't parse the decompressed file - expected json",
  $error_no_data_in_json = 4 => "Missing variable in the decompressed json: %s"
}

def fatal(code, *args)
  $stderr.printf $errors_dictionary[code] + "\n", *args
  exit code
end

file = ARGV[0]
fatal($error_no_file_argument_given) if file.nil?

json_string = `gunzip -c #{file}`
fatal($error_could_not_unzip_file) if $?.to_i != 0

begin
  json = JSON.parse(json_string)
rescue
end
fatal $error_could_not_parse_json if json.nil?

vars = ["md5", "arch", "env_GCC_PREPROCESSOR_DEFINITIONS__DEBUG", "rollout_appKey", "CFBundleShortVersionString", "CFBundleVersion", "rollout_build"]
curl_args = vars.map() { |var|
  value = json[var]
  fatal $error_no_data_in_json, var if value.nil?
  var + "=" + json[var]
}.join "&"

server_env = ENV["ROLLOUT_structureUploadingServer"]
server = server_env ? server_env : "upload.rollout.io"

curl_cmd = "curl -F structure=@#{file} 'http://" + server + "/build/structures?" + curl_args + "'"

system curl_cmd
