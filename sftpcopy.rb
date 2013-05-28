#!/use/bin/env ruby

#NOTE: SEND ALL MESSAGES TO STDIO! This is to be used in bash scripts. 

#Usage examples: 

#Downloading 
# `sftpcopy --download -h host -u username -p password -r /remote/path -l /local/path`

#Uploading
# `sftpcopy --upload -h host -u username -p password -l /local/path -r /remote/path`  

require 'optparse'
require 'net/sftp'


options = {}
OptionParser.new do |opts|
    opts.on('-h','--host HOST', "SFTP Host Address") do |i|
    	options[:host] = i
    end
    opts.on('-u','--username USERNAME',"Username for your SFTP account") do |i|
    	options[:username] = i
    end
    opts.on('-p','--password PASSWD',"Password for your SFTP account") do |i|
    	options[:password] = i
    end
    opts.on('--download',"Download mode") do |i|
    	options[:download] = true
    end
    opts.on('--upload', "Upload mode") do |i|
    	options[:upload] = true
    end
	opts.on('-l','--local FILE',"Local file or dir.") do |i|
		options[:local_file_or_dir] = i
	end
	opts.on('-r','--remote FILE',"Remote file or dir.") do |i|
		options[:remote_file_or_dir] = i
	end
	#Display help screen
	opts.on('--help','Display this screen') do 
		puts opts
		exit
	end
end

#Handles messages from SFTP upload session and sends them to STDI/O
class uploadMsgHandler
    def on_open(uploader, file)
   		puts "starting upload: #{file.local} -> #{file.remote} (#{file.size} bytes)"
    end

    def on_put(uploader, file, offset, data)
      	puts "writing #{data.length} bytes to #{file.remote} starting at #{offset}"
    end

    def on_close(uploader, file)
      	puts "finished with #{file.remote}"
    end

    def on_mkdir(uploader, path)
      	puts "creating directory #{path}"
    end

    def on_finish(uploader)
      	puts "all done!"
    end
end

#Handles messages from SFTP download session and sends them to STDI/O
class downloadMsgHandler
	def on_open(downloader, file)
		puts "starting download: #{file.remote} -> #{file.local} (#{file.size} bytes)"
	end

	def on_get(downloader, file, offset, data)
		puts "writing #{data.length} bytes to #{file.remote} starting at #{offset}"
	end

	def on_close(downloader, file)
		puts "finished with #{file.remote}"
	end

	def on_mkdir(downloader, path)
		puts "creating directory #{path}"
	end

	def on_finish(downloader)
		puts "all done!"
	end
end

def upload(host, username, password, path_to_local_file_or_dir, path_to_remote_dir)
	Net::SFTP.start(host, username, {:password => password, :progress => uploadMsgHandler.new} ) do |sftp|
		#TODO: Add logging
		sftp.upload!(path_to_local_file_or_dir, path_to_remote_dir)
	end
end

def download(host, username, password, path_to_remote_file_or_dir, path_to_local_dir)
	Net::SFTP.start(host, username, {:password => password, :progres => downloadMsgHandler.new) do |sftp|
		#TODO: Add logging
		sftp.download!(path_to_remote_file_or_dir, path_to_local_dir)
	end
end

if options[:download] === true
	download(options[:host], options[:username], options[:password], options[:remote_file_or_dir], options[:local_file_or_dir])
end

if options[:upload] === true
   upload(options[:host], options[:username], options[:password], options[:local_file_or_dir], options[:remote_file_or_dir])
end