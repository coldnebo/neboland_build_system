# use bundler environment
require 'rubygems'
require 'bundler/setup'
# add lib to loadpath
$:.unshift File.join(File.dirname(__FILE__), 'lib')


require 'helpers'
require 'pry'


# is this useful if a lot of changes in source are overwritten?
desc "update source -- pulls fresh from server"
task :update do 
  sources.each do |file|
    ftp.download_to("source", file)
  end
end


desc "build the server"
task :build do 
  # build is always fresh
  FileUtils.rm_rf("build") if Dir.exist?("build")
  Dir.mkdir("build") 

  print "processing"
  sources.each do |file|
    process("source", "build", file)
  end
  puts "done!"

end


desc "deploy the server"
task :deploy do 
  sources.each do |file|
    ftp.upload_from("build", file)
  end
end