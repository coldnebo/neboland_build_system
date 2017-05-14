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
  ftp.download_to("source", sources)
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
  ftp.upload_from("build", sources)
end

desc "update steam managed mods to server"
task :update_mods do 

  Dir.chdir(abs_path(config.mods.dir)) do |path|

    steam_mods = (config.mods.client.steam | config.mods.server.steam).sort
    manifest = steam_mods.map {|d| Dir.glob(File.join(path, d, '**', '*'))}.flatten
    manifest = manifest.map {|f| f.gsub(/^#{path}\//,'') }   # make it relative path for upload
    files = manifest.select{|f| File.file?(f) }
    dirs = manifest.select{|f| File.directory?(f) } + steam_mods
    files.sort!
    dirs.sort!

    # extract the key files...
    key_files = files.select{|f| f =~ /\.bikey$/ }
    key_dir = root_to(File.join('source','keys'))
    FileUtils.mkdir_p(key_dir) unless Dir.exist?(key_dir)

    # copy them to the local source dir...
    key_files.each do |key_file|
      FileUtils.cp(key_file, key_dir, verbose: true)
    end

    # and add them to the source.manifest if they aren't already present...
    keys = key_files.map{|kf| File.join(key_dir,File.basename(kf)).gsub(root_to("source/"),'') }
    sm = File.read(root_to("source.manifest"))
    remaining_keys = keys.reject{|k| sm =~ /#{k}/}
    unless remaining_keys.empty?
      File.open(root_to("source.manifest"), 'a') do |f|
        f.puts remaining_keys.join("\n")
      end
    end

    ftp.mkdirs(dirs)
    ftp.upload_from(".", files, false)
  end

end


desc "generate command line for mods"
task :generate do 
  client_mods = config.mods.client.map{|k,v| v}.flatten.sort
  server_mods = config.mods.server.map{|k,v| v}.flatten.sort

  puts "mod=#{client_mods.join(";")}"
  puts "servermod=#{server_mods.join(";")}"

end