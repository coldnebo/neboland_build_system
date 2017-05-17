

require 'rake/clean'

CLEAN.include('build/**/*')
CLOBBER.include('stage/**/*')


desc "build the server"
multitask build: %w[build_erb build_untouched build_mods]
task :default => [:build]


directory 'build'
directory 'stage'

erb_files = Rake::FileList[
  'source/A3DS/server.cfg'
]

untouched_files = Rake::FileList[
  'source/keys/*.bikey'
]


task :build_erb do 
  erb_files.each do |f|
    process(f,f.pathmap("%{^source,build}p"))
    stage(f.pathmap("%{^source,build}p"),f.pathmap("%{^source,stage}p"))
  end
end

task :build_untouched do 
  untouched_files.each do |f|
    stage(f,f.pathmap("%{^source,stage}p"))
  end
end


multitask build_mods: %w[build_infistar]

task :build_infistar do 
  source_dir = "source/mods/infiSTAR.de_EXILE/SERVER_ARMA3_FOLDER/@infiSTAR_Exile/addons/a3_infiSTAR_Exile"
  files = Rake::FileList["#{source_dir}/**/*"]
  files = files.select{|f| File.file?(f)}
  build_dir = "build/mods/a3_infiSTAR_Exile"

  process_files = Rake::FileList["#{source_dir}/**/EXILE_AHAT_CONFIG.hpp"]

  files.each do |f|
    build_file = f.pathmap("%{^#{source_dir},#{build_dir}}p")
    if process_files.include?(f)
      process(f,build_file)
    else
      stage(f,build_file)
    end
  end

end