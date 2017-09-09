

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



# ================== ExileServer PBOs =====================

# https://github.com/Defent/DMS_Exile
build_pbo({
        name: "a3_dms",
  source_dir: "source/mods/DMS_Exile/@ExileServer/addons/a3_dms",
   build_dir: "build/mods/a3_dms",
  target_pbo: "stage/@ExileServer/addons/a3_dms.pbo",
      prefix: "x\\addons\\DMS" 
}) 

# https://github.com/kuplion/a3_exile_occupation
build_pbo({
        name: "a3_exile_occupation",
  source_dir: "source/mods/occupation/source/a3_exile_occupation",
   build_dir: "build/mods/a3_exile_occupation",
  target_pbo: "stage/@ExileServer/addons/a3_exile_occupation.pbo",
      prefix: "x\\addons\\a3_exile_occupation" 
}) 

# not under github, but you can go to http://www.exilemod.com/downloads/
# and download the server zip, depbo the exile_server_config.pbo part to the source dir.
build_pbo({
        name: "exile_server_config",
  source_dir: "source/mods/exile_server_config",
  target_pbo: "stage/@ExileServer/addons/exile_server_config.pbo",
      prefix: "exile_server_config" 
}) do |conf|

  conf.process_files = Rake::FileList["#{conf.source_dir}/**/config.cpp"]

end

# https://github.com/patrix87/ExileZ-2
build_pbo({
        name: "exilez",
  source_dir: "source/mods/ExileZ-2/exilez",
   build_dir: "build/mods/exilez",
  target_pbo: "stage/@ExileServer/addons/exilez.pbo",
      prefix: "exilez" 
}) 

# commercial product.  see https://infistar.de/eng/product/infistar-exile
build_pbo({
        name: "infiSTAR_Exile",
  source_dir: "source/mods/infiSTAR.de_EXILE/SERVER_ARMA3_FOLDER/@infiSTAR_Exile/addons/a3_infiSTAR_Exile",
   build_dir: "build/mods/a3_infiSTAR_Exile",
  target_pbo: "stage/@ExileServer/addons/a3_infiSTAR_Exile.pbo",
      prefix: "a3_infiSTAR_Exile" 
}) do |conf|

  conf.process_files = Rake::FileList["#{conf.source_dir}/**/EXILE_AHAT_CONFIG.hpp"]

  # additional copy files...
  dlls =  Rake::FileList["source/mods/infiSTAR.de_EXILE/SERVER_ARMA3_FOLDER/@infiSTAR_Exile/*.dll"]
  dlls.each do |f|
    stage(f,f.pathmap("stage/%f"))
  end

end


# ===================== MAP/MISSION PBOs =======================

# also from the server zip at http://www.exilemod.com/downloads/
# however, my copy is also modified for NeboLand's Arma Server.
# you can take mine or use your own.
#
# My take:
# Exile set the stage as a place for 'survivor' criminals. But things have gotten much worse. 
# Zombies have taken over towns, and a downed plane from Isla Sorna, results in a small group of 
# raptors springing loose.
# UNDER EVOLUTION.
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

  trader_files = Rake::FileList["source/mods/Trader-Mod/TRADERS/**/*"]
  trader_files = trader_files.select{|f| File.file?(f) }

  trader_files.each do |f|
    build_file = f.pathmap("%{^source/mods/Trader-Mod/TRADERS,#{conf.build_dir}/TRADERS}p")
    stage(f,build_file)
  end

end

# attempt at merging the ALiVE mod with Exile.  The idea is to have Exile and DMS missions 
# against a larger backdrop of asymetric warfare.  ALiVE is used as an alternative to 
# DMS Occupation and possibly ExileZ-2 to drive non-DMS "bandits", zombies and a police military force
# in strategic skirmishes and patrols across the island. 
# UNDER CONSTRUCTION.
build_pbo({
        name: "ExileAlive.Tanoa",
  source_dir: "source/mods/ExileAlive.Tanoa",
  target_pbo: "stage/mpmissions/ExileAlive.Tanoa.pbo",
      prefix: "ExileAlive.Tanoa"
}) do |conf|

  infistar_files = Rake::FileList["source/mods/infiSTAR.de_EXILE/MPMission/**/*"]

  infistar_files.each do |f|
    build_file = f.pathmap("%{^source/mods/infiSTAR.de_EXILE/MPMission,#{conf.build_dir}}p")
    stage(f,build_file)
  end

end

# from sample missions.  see http://alivemod.com/missions
build_pbo({
        name: "Alive: Operation_Landlord.Altis",
  source_dir: "source/mods/Operation_Landlord.Altis",
  target_pbo: "stage/mpmissions/Operation_Landlord.Altis.pbo",
      prefix: "Operation_Landlord.Altis"
}) 



# place after all the build_pbo commands...
multitask build_mods: pbo_targets

