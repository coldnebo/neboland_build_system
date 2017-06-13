require 'config'
require 'net/ftp'
require 'erubis'

# convert to unix minus the drive letter. assumes same drive and never hops drives.
def abs_path(path)
  cpath = `cygpath -au '#{path}'`.strip[2..-1]
end

def win_path(path)
  wpath = `cygpath -aw '#{path}'`.strip
end

# @param from [String] defaults to project root path.
# e.g. root_to('dir', 'file')
def root_to(file)
  root_path = abs_path File.dirname(File.dirname(__FILE__))
  path = File.join(root_path, file)
end

def config
  @config ||= Config.load(root_to("config.json"))
end

def ftp
  @ftp ||= Object.new.tap {|o| 
    def o.download_to(local_dir, files)
      ftp = Net::FTP.new
      ftp.connect(config.ftp.host, config.ftp.port)
      ftp.login(config.ftp.username, config.ftp.password)

      files.each do |file|
        local_file = File.join(local_dir, file)
        next if File.exist?(local_file)
        remote_file = File.join(config.ftp.basedir,file)

        puts "#{local_file} <- #{remote_file}"
        ftp.get(remote_file, local_file)
      end
    ensure
      ftp.close
    end

    def o.upload_from(local_dir, files, remote_overwrite=true)
      ftp = Net::FTP.new
      ftp.connect(config.ftp.host, config.ftp.port)
      ftp.login(config.ftp.username, config.ftp.password)

      files.each do |file|
        local_file = File.join(local_dir, file)
        next unless File.exist?(local_file)
        remote_file = File.join(config.ftp.basedir,file)

        remote_exist = true
        begin 
          ftp.size(remote_file)
        rescue Net::FTPPermError => e 
          remote_exist = false
        end
        
        if !remote_exist || (remote_exist && remote_overwrite)
          puts "#{local_file} -> #{remote_file}"
          ftp.put(local_file, remote_file)
        end
      end
    ensure
      ftp.close
    end

    def o.mkdirs(dirs)
      ftp = Net::FTP.new
      ftp.connect(config.ftp.host, config.ftp.port)
      ftp.login(config.ftp.username, config.ftp.password)

      dirs.each do |dir|
        remote_dir = File.join(config.ftp.basedir,dir)

        puts "creating #{remote_dir}"
        begin
          ftp.mkdir(remote_dir)
        rescue Net::FTPReplyError => e 
          raise unless e.message =~ /^200 Command okay/
        end
      end
    ensure
      ftp.close
    end
  }
end

# uses Erubis to preprocess a file
# @param src the input file with erb templating
# @param dst the preprocessed output file
def process(src, dst)
  return unless File.exist?(src)
  input = File.read(src)
  eruby = Erubis::Eruby.new(input)
  dst_dir = File.dirname(dst)
  FileUtils.mkdir_p(dst_dir) unless Dir.exist?(dst_dir)
  File.open(dst, 'w+') do |f|
    f.puts eruby.result(binding())
  end
  puts "erb #{src} -> #{dst}"
end

# copies the file from src to dst, ensuring the same dir structure.
def stage(src, dst)
  return unless File.exist?(src)
  dst_dir = File.dirname(dst)
  FileUtils.mkdir_p(dst_dir) unless Dir.exist?(dst_dir)
  FileUtils.cp(src, dst)
  puts "staged #{src} -> #{dst}"
end

# calls arma3 tools to actually package the pbo
# note that you have to be logged in for steam tools to work.
def make_pbo(src_dir, dst_pbo, opts={})
  addon_builder = %{"#{config.tools.AddonBuilder}"}
  
  include_file = "source/mods/addonbuilder_includes.txt"
  include_opt = %{-include="#{abs_path(include_file)}"}

  prefix_opt = %{-prefix="#{opts[:prefix]}"} unless opts[:prefix].nil?
  sign_opt = %{-sign="#{abs_path(opts[:sign])}"} unless opts[:sign].nil?
  pack_only_opt = %{-packonly} unless opts[:packonly].nil?
  
  dir = File.dirname(dst_pbo)
  cmd = %{#{addon_builder} "#{abs_path(src_dir)}" "#{abs_path(dir)}" -clear -project="#{abs_path(src_dir)}"}
  cmd = cmd + " #{include_opt} #{prefix_opt} #{sign_opt}"

  #cmd = %{#{addon_builder} -help}
  puts cmd
  out = `#{cmd}`
  puts out
  if out =~ /Arma 3 Tools path not set/
    puts "[BUILD_WARNING]: You need to be logged in to Steam and have the Arma 3 Tools (http://store.steampowered.com/app/233800/Arma_3_Tools/) in your Library."
  end
end


def pbo_targets
  @pbo_targets ||= []
end

# creates a rake file task coordinating the build of a pbo 
def build_pbo(config, &block)
  conf = OpenStruct.new(config)
  conf.source_files = Rake::FileList["#{conf.source_dir}/**/*"].select{|f| File.file?(f)}
  rake_block = Proc.new {|t,args| 
    # if files in your pbos require access to config.json vars, you 
    # can preprocess them through Erubis by adding the file list to 
    # conf.process_files
    conf.process_files = []

    # the build_dir is usually the same as the source_dir, so it's calculated if not provided...
    conf.build_dir = conf.source_dir.pathmap("%{^source/,build/}p") if conf.build_dir.nil?
    
    yield(conf) if block_given?

    conf.source_files.each do |f|
      build_file = f.pathmap("%{^#{conf.source_dir},#{conf.build_dir}}p")
      if !conf.process_files.empty? && conf.process_files.include?(f)
        process(f,build_file)
      else
        stage(f,build_file)
      end
    end

    make_pbo(conf.build_dir, conf.target_pbo, prefix: conf.prefix) 
  }
  file(conf.target_pbo => conf.source_files, &rake_block)
  pbo_targets.push(conf.target_pbo)
end
