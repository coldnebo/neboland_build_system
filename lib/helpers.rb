require 'config'
require 'net/ftp'
require 'erubis'

# convert to unix minus the drive letter. assumes same drive and never hops drives.
def abs_path(path)
  cpath = `cygpath -au '#{path}'`.strip[2..-1]
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
      Net::FTP.open(config.ftp.host) do |ftp|
        ftp.connect(config.ftp.host, config.ftp.port)
        ftp.login(config.ftp.username, config.ftp.password)

        files.each do |file|
          local_file = File.join(local_dir, file)
          next if File.exist?(local_file)
          remote_file = File.join(config.ftp.basedir,file)

          puts "#{local_file} <- #{remote_file}"
          ftp.get(remote_file, local_file)
        end
      end
    end

    def o.upload_from(local_dir, files, remote_overwrite=true)
      Net::FTP.open(config.ftp.host) do |ftp|
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
      end
    end

    def o.mkdirs(dirs)
      Net::FTP.open(config.ftp.host) do |ftp|
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
      end
    end
  }
end


def process(src, dst, file)
  src_file = File.join(src, file)
  return unless File.exist?(src_file)

  dst_file = File.join(dst, file)
  input = File.read(src_file)
  eruby = Erubis::Eruby.new(input)

  dst_dir = File.dirname(dst_file)
  FileUtils.mkdir_p(dst_dir) unless Dir.exist?(dst_dir)
  File.open(dst_file, 'w+') do |f|
    f.puts eruby.result(binding())
  end
  puts "erb #{src_file} -> #{dst_file}"
end


def stage(src, dst, file)
  src_file = File.join(src, file)
  return unless File.exist?(src_file)

  dst_file = File.join(dst, file)
  dst_dir = File.dirname(dst_file)
  FileUtils.mkdir_p(dst_dir) unless Dir.exist?(dst_dir)
    
  FileUtils.cp(src_file, dst_file)
  puts "staged #{src_file} -> #{dst_file}"
end

