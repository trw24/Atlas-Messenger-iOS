require 'rake'
require 'json'

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
