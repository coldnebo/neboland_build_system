

require 'rake/clean'

CLEAN.include('build/**/*')
CLOBBER.include('stage/**/*')


desc "build the server"
multitask build: %w[build_erb build_untouched build_mods]
task :default => [:build]


directory 'build'
directory 'stage'


# ================= this is for handling files outside of PBOs =============

# files to be pre-processed via Erubis 
erb_files = Rake::FileList[
  'source/A3DS/server.cfg',
  'source/@ExileServer/config.cfg'
]

# files to be copied directly
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



# ================== PBOs =====================


build_pbo({
        name: "exile_server_config",
  source_dir: "source/mods/exile_server_config",
  target_pbo: "stage/@ExileServer/addons/exile_server_config.pbo",
      prefix: "exile_server_config" 
}) do |conf|

  conf.process_files = Rake::FileList["#{conf.source_dir}/**/config.cpp"]

end



build_pbo({
        name: "a3_dms",
  source_dir: "source/mods/DMS_Exile/@ExileServer/addons/a3_dms",
   build_dir: "build/mods/a3_dms",
  target_pbo: "stage/@ExileServer/addons/a3_dms.pbo",
      prefix: "x\\addons\\DMS" 
}) 


build_pbo({
        name: "infiSTAR_Exile",
  source_dir: "source/mods/infiSTAR.de_EXILE/SERVER_ARMA3_FOLDER/@infiSTAR_Exile/addons/a3_infiSTAR_Exile",
   build_dir: "build/mods/a3_infiSTAR_Exile",
  target_pbo: "stage/@ExileServer/addons/a3_infiSTAR_Exile.pbo",
      prefix: "a3_infiSTAR_Exile" 
}) do |conf|

  conf.process_files = Rake::FileList["#{conf.source_dir}/**/EXILE_AHAT_CONFIG.hpp"]

  # additional copy files...
  dlls = Rake::FileList["source/mods/infiSTAR.de_EXILE/SERVER_ARMA3_FOLDER/*.dll"]
  dlls.each do |f|
    stage(f,f.pathmap("stage/%f"))
  end

end


build_pbo({
        name: "Exile.Tanoa",
  source_dir: "source/mods/Exile.Tanoa",
  target_pbo: "stage/mpmissions/Exile.Tanoa.pbo",
      prefix: "Exile.Tanoa"
}) do |conf|

  infistar_files = Rake::FileList["source/mods/infiSTAR.de_EXILE/MPMission/**/*"]

  infistar_files.each do |f|
    build_file = f.pathmap("%{^source/mods/infiSTAR.de_EXILE/MPMission,#{conf.build_dir}}p")
    stage(f,build_file)
  end

end


build_pbo({
        name: "ExileAlive.Tanoa",
  source_dir: "source/mods/ExileAlive.Tanoa",
  target_pbo: "stage/mpmissions/ExileAlive.Tanoa.pbo",
      prefix: "ExileAlive.Tanoa"
}) 



build_pbo({
        name: "Alive: Operation_Landlord.Altis",
  source_dir: "source/mods/Operation_Landlord.Altis",
  target_pbo: "stage/mpmissions/Operation_Landlord.Altis.pbo",
      prefix: "Operation_Landlord.Altis"
}) 


#D:\games\NeboLand2\source\mods\occupation\source\a3_exile_occupation\$PREFIX$
build_pbo({
        name: "a3_dms",
  source_dir: "source/mods/occupation/source/a3_exile_occupation",
   build_dir: "build/mods/a3_exile_occupation",
  target_pbo: "stage/@ExileServer/addons/a3_exile_occupation.pbo",
      prefix: "x\\addons\\a3_exile_occupation" 
}) 



# place after all the build_pbo commands...
multitask build_mods: pbo_targets

