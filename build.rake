

require 'rake/clean'

CLEAN.include('build/**/*')
CLOBBER.include('stage/**/*')


desc "build the server"
multitask build: %w[build_erb build_untouched]
task :default => [:build]


directory 'build'
directory 'stage'

erb_files = Rake::FileList[
  'A3DS/server.cfg'
]

untouched_files = Rake::FileList[
  'source/keys/*.bikey'
]


task :build_erb do 
  erb_files.each do |f|
    process('source','build',f)
    stage('build','stage',f)
  end
end

task :build_untouched do 
  untouched_files.each do |f|
    stage('source','stage',f.pathmap("%-1d/%f"))
  end
end


