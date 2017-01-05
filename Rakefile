require 'rake'
require 'json'
require 'byebug'

def set(key, value) 
  file = File.open("Layerfile", "rb")
  jsonString = file.read
  json = JSON.parse(jsonString)
  if value == nil
    json.delete(key)
  else
    json[key] = value
  end
  jsonString = JSON.pretty_generate(json)
  File.open('Layerfile', 'w') { |file| file.write(jsonString) }
  puts(jsonString)
end

desc "Initialize the project for the first time"
task :init do
  podUpdate = "rbenv exec pod update"
  puts green(podUpdate)
  system podUpdate
 
  puts green("Configure your App ID") 
  puts "To set your app ID please run:"
  puts
  puts "\trake configure:setAppID[\"{YOUR_APP_ID}\"]"
  puts
  puts "by replacing {YOUR_APP_ID} with your Layer App ID."
  puts
  puts grey("Done Initializing your project")
end

desc "Layer configuration"
namespace :configure do
  desc "Set a Layerfile Key"
  task :set, [:key, :value] do |t, args|
    key = args[:key] 
    value = args[:value]
    set(key, value)  
  end  

  desc "Set the Layer AppID"  
  task :setAppID, [:appID] do |t, args|
    set("appID", args[:appID])
  end
  desc "Clear the Layerfile"
  task :clear do
    File.open('Layerfile', 'w') { |file| file.write("{\n}") }
    puts("Done")
  end
end

def green(string)
 "\033[1;32m* #{string}\033[0m"
end

def yellow(string)
 "\033[1;33m>> #{string}\033[0m"
end

def grey(string)
 "\033[0;37m#{string}\033[0m"
end
