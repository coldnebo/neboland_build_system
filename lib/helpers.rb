require 'config'
require 'net/ftp'
require 'erubis'


def config
  @config ||= Config.load("config.json")
end

def ftp
  @ftp ||= Object.new.tap {|o| 
    def o.download_to(local_dir, file)
      local_file = File.join(local_dir, file)
      
      # DON'T OVERWRITE LOCAL SOURCE - if devs want to pull latest copy, they should
      # 1) git commit that source
      # 2) locally remove the file
      # 3) rake update
      # 4) check git for changes and merge back in any build vars
      # 5) git commit again.
      return if File.exist?(local_file)

      Net::FTP.open(config.ftp.host) do |ftp|
        ftp.connect(config.ftp.host, config.ftp.port)
        ftp.login(config.ftp.username, config.ftp.password)
        remote_file = File.join(config.ftp.basedir,file)
        puts "#{local_file} <- #{remote_file}"
        ftp.get(remote_file, local_file)
      end
    end

    def o.upload_from(local_dir, file)
      local_file = File.join(local_dir, file)
      return unless File.exist?(local_file)

      Net::FTP.open(config.ftp.host) do |ftp|
        ftp.connect(config.ftp.host, config.ftp.port)
        ftp.login(config.ftp.username, config.ftp.password)
        remote_file = File.join(config.ftp.basedir,file)
        puts "#{local_file} -> #{remote_file}"
        ftp.put(local_file, remote_file)
      end
    end
  }
end

def sources
  @sources ||= File.read("source.manifest").lines.map{|l| l.strip}
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
  print "."
end