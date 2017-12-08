# use bundler environment
require 'rubygems'
require 'bundler/setup'
# add lib to loadpath
$:.unshift File.join(File.dirname(__FILE__), 'lib')


require 'helpers'
require 'pry'  # good for on-the-fly debugging

import 'build.rake'



staged = FileList['stage/**/*']

desc "deploy the server"
task :deploy => staged do 
  files = staged.select{|f| File.file?(f)}.map{|f| f.pathmap("%{^stage/,}p")}
  ftp.upload_from("stage", files)
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
    key_src_dir = root_to(File.join('source','keys'))
    key_stg_dir = root_to(File.join('stage','keys'))
    FileUtils.mkdir_p(key_src_dir) unless Dir.exist?(key_src_dir)
    FileUtils.mkdir_p(key_stg_dir) unless Dir.exist?(key_stg_dir)

    # copy them to the local source dir...
    key_files.each do |key_file|
      FileUtils.cp(key_file, key_src_dir, verbose: true)
      FileUtils.cp(key_file, key_stg_dir, verbose: true)
    end

    # copy an admin only client side key for @Ares
    FileUtils.cp("@Ares/keys/Ares_1_8_0.bikey", key_src_dir, verbose: true)
    FileUtils.cp("@Ares/keys/Ares_1_8_0.bikey", key_stg_dir, verbose: true)

    ftp.mkdirs(dirs)
    ftp.upload_from(".", files, false)
  end

  # upload the new keys too
  key_files = Rake::FileList['source/keys/*.bikey']
  files = key_files.select{|f| File.file?(f)}.map{|f| f.pathmap("%{^source/,}p")}
  files.each do |f|
    stage(f,f.pathmap("%{^source,stage}p"))
  end
  ftp.upload_from("stage", files)
end


desc "generate command line for mods"
task :generate do 
  client_mods = config.mods.client.map{|k,v| v}.flatten.sort
  server_mods = config.mods.server.map{|k,v| v}.flatten.sort

  puts "mod=#{client_mods.join(";")}"
  puts "servermod=#{server_mods.join(";")}"

end


desc "updates git submodules"
task :update do 
  exec("git submodule update --remote --rebase")
end
