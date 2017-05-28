

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
  "stage/mpmissions/Exile.Tanoa.pbo",
  "stage/mpmissions/Operation_Landlord.Altis.pbo"
]






build_pbo({
        name: "infiSTAR_Exile",
  source_dir: "source/mods/infiSTAR.de_EXILE/SERVER_ARMA3_FOLDER/@infiSTAR_Exile/addons/a3_infiSTAR_Exile",
   build_dir: "build/mods/a3_infiSTAR_Exile",
  target_pbo: "stage/@ExileServer/addons/a3_infiSTAR_Exile.pbo"
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

  make_pbo(conf.build_dir, conf.target_pbo)

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
  target_pbo: "stage/mpmissions/Exile.Tanoa.pbo"
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

  make_pbo(conf.build_dir, conf.target_pbo)

end


build_pbo({
        name: "Alive: Operation_Landlord.Altis",
  source_dir: "source/mods/Operation_Landlord.Altis",
   build_dir: "build/mods/Operation_Landlord.Altis",
  target_pbo: "stage/mpmissions/Operation_Landlord.Altis.pbo"
}) do |conf|

  conf.source_files.each do |f|
    build_file = f.pathmap("%{^#{conf.source_dir},#{conf.build_dir}}p")
    stage(f,build_file)
  end

  make_pbo(conf.build_dir, conf.target_pbo)

end



# file "stage/mpmissions/Operation_Landlord.Altis.pbo" do 
#   target_pbo = "stage/mpmissions/Operation_Landlord.Altis.pbo"
#   source = "source/mods/Operation Landlord - SpyderBlack723/Operation_Landlord.Altis.pbo"
#   stage(source,target_pbo)
# end