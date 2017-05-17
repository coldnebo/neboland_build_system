

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


multitask build_mods: [
  "stage/@ExileServer/addons/a3_infiSTAR_Exile.pbo",
  "stage/mpmissions/Exile.Tanoa.pbo"
]
infistar = {}
infistar[:source_dir] = "source/mods/infiSTAR.de_EXILE/SERVER_ARMA3_FOLDER/@infiSTAR_Exile/addons/a3_infiSTAR_Exile"
infistar[:files] = Rake::FileList["#{infistar[:source_dir]}/**/*"].select{|f| File.file?(f)}


file "stage/@ExileServer/addons/a3_infiSTAR_Exile.pbo" => infistar[:files] do 
  
  build_dir = "build/mods/a3_infiSTAR_Exile"
  target_pbo = "stage/@ExileServer/addons/a3_infiSTAR_Exile.pbo"

  process_files = Rake::FileList["#{infistar[:source_dir]}/**/EXILE_AHAT_CONFIG.hpp"]

  infistar[:files].each do |f|
    build_file = f.pathmap("%{^#{infistar[:source_dir]},#{build_dir}}p")
    if process_files.include?(f)
      process(f,build_file)
    else
      stage(f,build_file)
    end
  end

  make_pbo(build_dir,target_pbo)

  dlls = Rake::FileList["source/mods/infiSTAR.de_EXILE/SERVER_ARMA3_FOLDER/*.dll"]
  dlls.each do |f|
    stage(f,f.pathmap("stage/%f"))
  end

end

mission = {}
mission[:source_dir] = "source/mods/Exile.Tanoa"
mission[:files] = Rake::FileList["#{mission[:source_dir]}/**/*"].select{|f| File.file?(f)}
file "stage/mpmissions/Exile.Tanoa.pbo" => mission[:files] do 

  build_dir = "build/mods/Exile.Tanoa"
  target_pbo = "stage/mpmissions/Exile.Tanoa.pbo"

  infistar_files = Rake::FileList["source/mods/infiSTAR.de_EXILE/MPMission/**/*"]

  mission[:files].each do |f|
    build_file = f.pathmap("%{^#{mission[:source_dir]},#{build_dir}}p")
    stage(f,build_file)
  end

  infistar_files.each do |f|
    build_file = f.pathmap("%{^source/mods/infiSTAR.de_EXILE/MPMission,#{build_dir}}p")
    stage(f,build_file)
  end

  make_pbo(build_dir,target_pbo)

end