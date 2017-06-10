

require 'rake/clean'

CLEAN.include('build/**/*')
CLOBBER.include('stage/**/*')


desc "build the server"
multitask build: %w[build_erb build_untouched build_mods]
task :default => [:build]


directory 'build'
directory 'stage'

erb_files = Rake::FileList[
  'source/A3DS/server.cfg',
  'source/@ExileServer/config.cfg'
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
  "stage/mpmissions/Exile.Tanoa.pbo",
  "stage/mpmissions/ExileAlive.Tanoa.pbo",
  "stage/mpmissions/Operation_Landlord.Altis.pbo",
  "stage/@ExileServer/addons/a3_dms.pbo",
  "stage/@ExileServer/addons/exile_server_config.pbo"
]




build_pbo({
        name: "exile_server_config",
  source_dir: "source/mods/exile_server_config",
   build_dir: "build/mods/exile_server_config",
  target_pbo: "stage/@ExileServer/addons/exile_server_config.pbo",
      prefix: "exile_server_config" 
}) do |conf|

  conf.source_files.each do |f|
    build_file = f.pathmap("%{^#{conf.source_dir},#{conf.build_dir}}p")
    process(f,build_file)
  end

  make_pbo(conf.build_dir, conf.target_pbo, prefix: conf.prefix)

end



build_pbo({
        name: "a3_dms",
  source_dir: "source/mods/a3_dms",
   build_dir: "build/mods/a3_dms",
  target_pbo: "stage/@ExileServer/addons/a3_dms.pbo",
      prefix: "x\\addons\\DMS" 
}) do |conf|

  conf.source_files.each do |f|
    build_file = f.pathmap("%{^#{conf.source_dir},#{conf.build_dir}}p")
    stage(f,build_file)
  end

  make_pbo(conf.build_dir, conf.target_pbo, prefix: conf.prefix)

end


build_pbo({
        name: "infiSTAR_Exile",
  source_dir: "source/mods/infiSTAR.de_EXILE/SERVER_ARMA3_FOLDER/@infiSTAR_Exile/addons/a3_infiSTAR_Exile",
   build_dir: "build/mods/a3_infiSTAR_Exile",
  target_pbo: "stage/@ExileServer/addons/a3_infiSTAR_Exile.pbo",
      prefix: "a3_infiSTAR_Exile" 
}) do |conf|

  process_files = Rake::FileList["#{conf.source_dir}/**/EXILE_AHAT_CONFIG.hpp"]

  conf.source_files.each do |f|
    build_file = f.pathmap("%{^#{conf.source_dir},#{conf.build_dir}}p")
    if process_files.include?(f)
      process(f,build_file)
    else
      stage(f,build_file)
    end
  end

  make_pbo(conf.build_dir, conf.target_pbo, prefix: conf.prefix)

  # additional copy files...
  dlls = Rake::FileList["source/mods/infiSTAR.de_EXILE/SERVER_ARMA3_FOLDER/*.dll"]
  dlls.each do |f|
    stage(f,f.pathmap("stage/%f"))
  end

end


build_pbo({
        name: "Exile.Tanoa",
  source_dir: "source/mods/Exile.Tanoa",
   build_dir: "build/mods/Exile.Tanoa",
  target_pbo: "stage/mpmissions/Exile.Tanoa.pbo",
      prefix: "Exile.Tanoa"
}) do |conf|

  infistar_files = Rake::FileList["source/mods/infiSTAR.de_EXILE/MPMission/**/*"]

  conf.source_files.each do |f|
    build_file = f.pathmap("%{^#{conf.source_dir},#{conf.build_dir}}p")
    stage(f,build_file)
  end

  infistar_files.each do |f|
    build_file = f.pathmap("%{^source/mods/infiSTAR.de_EXILE/MPMission,#{conf.build_dir}}p")
    stage(f,build_file)
  end

  make_pbo(conf.build_dir, conf.target_pbo, prefix: conf.prefix)

end


build_pbo({
        name: "ExileAlive.Tanoa",
  source_dir: "source/mods/ExileAlive.Tanoa",
   build_dir: "build/mods/ExileAlive.Tanoa",
  target_pbo: "stage/mpmissions/ExileAlive.Tanoa.pbo",
      prefix: "ExileAlive.Tanoa"
}) do |conf|

  #infistar_files = Rake::FileList["source/mods/infiSTAR.de_EXILE/MPMission/**/*"]

  conf.source_files.each do |f|
    build_file = f.pathmap("%{^#{conf.source_dir},#{conf.build_dir}}p")
    stage(f,build_file)
  end

  # infistar_files.each do |f|
  #   build_file = f.pathmap("%{^source/mods/infiSTAR.de_EXILE/MPMission,#{conf.build_dir}}p")
  #   stage(f,build_file)
  # end

  make_pbo(conf.build_dir, conf.target_pbo, prefix: conf.prefix)

end



build_pbo({
        name: "Alive: Operation_Landlord.Altis",
  source_dir: "source/mods/Operation_Landlord.Altis",
   build_dir: "build/mods/Operation_Landlord.Altis",
  target_pbo: "stage/mpmissions/Operation_Landlord.Altis.pbo",
      prefix: "Operation_Landlord.Altis"
}) do |conf|

  conf.source_files.each do |f|
    build_file = f.pathmap("%{^#{conf.source_dir},#{conf.build_dir}}p")
    stage(f,build_file)
  end

  make_pbo(conf.build_dir, conf.target_pbo, prefix: conf.prefix)

end



# file "stage/mpmissions/Operation_Landlord.Altis.pbo" do 
#   target_pbo = "stage/mpmissions/Operation_Landlord.Altis.pbo"
#   source = "source/mods/Operation Landlord - SpyderBlack723/Operation_Landlord.Altis.pbo"
#   stage(source,target_pbo)
# end