require 'json'
require 'zlib'
require 'fog'
require 'tmpdir'
require 'logger'
require 'active_support/inflector'
require 'active_support/core_ext'

# 
# Provides iterators to access files on s3
#  Iterates over a collection of files on the cloud / AWS S3
#    Assumes files are gzipped, json format
#    iterates over all lines in the file, parse the json
#  
#

# TODO:
#  1. mock up and write tests
#  2. add file uploader
module CloudLoader
  
  DEFAULT_DB = "datadb"
  LOGGER = Logger.new($stdout)
  
  class Chunk
    include Enumerable

    attr_reader :remote_file
    def initialize(remote_file, storage)
      @remote_file=remote_file
      @storage=storage
    end

    def to_s
      @remote_file.key
    end
    #

    #  see http://stackoverflow.com/questions/1361892/how-to-decompress-gzip-string-in-ruby
    def each(&block)
      # TODO:  switch if file zipped or not      
      Zlib::GzipReader.new(StringIO.new(@remote_file.body), 
                             :external_encoding => @remote_file.body.encoding).each_line do |line|
          yield JSON.parse(line)
        end
      
    end

  end

  #see:  #http://fog.io/storage/
  #  http://stackoverflow.com/questions/15955991/how-to-list-all-files-in-an-s3-folder-using-fog-in-ruby
  class Loader
    include Enumerable

    DEFAULT_CREDENTIALS = { :provider => 'AWS',
        :aws_access_key_id => ENV['AWS_ACCESS_KEY_ID'],
        :aws_secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'],
        :region => ENV['EC2_REGION'] }

    attr_accessor :bucket, :path, :pattern, :credentials, :storage
    def initialize(opts = {})
      @opts = opts

     
      @bucket = opts[:bucket]
      @path = opts[:path]
      @pattern = opts[:pattern]
     # @pattern = /#{@pattern}/ if @pattern.is_a? String  jsut assume it is a string

      # broken for some reasion? need to test better
      # @credentials = DEFAULT_CREDENTIALS
      # @credentials.reverse_merge! opts[:credentials].symbolize_keys if opts[:credentials]
      
       @credentials=  opts[:credentials].symbolize_keys 
      @storage = Fog::Storage.new(credentials)
    end

    def load_file(filename)

    end

    # this is all screwed up...how does delimiter work?
    def each(&block)

      last_file_key = ""
      truncated = true

      while truncated
        files = @storage.directories.get(bucket, :prefix => path, :delimiter=>'/', :marker => last_file_key).files
        truncated = @storage.get_bucket(bucket, :prefix => path, :delimiter=>'/', :marker => last_file_key).body['IsTruncated']

        files.each do |file|
        #  next if pattern and not file.key =~ /#{pattern}/
          last_file_key = file.key
          yield Chunk.new(file,@storage)
        end

      end
    end

  end

end
# 
# # hack test .. works
# require 'trollop'
# opts = Trollop::options do
  # opt :bucket, "bucket", :short => "-b", :default => "cloud-crawler"
  # opt :path, "path on bucket", :short => "-p",  :default => "crawl-pages"
  # opt :pattern, "file patterns", :short => "-f", :default => "40UTC" #, :multi => true
# end
# 
# #opts = { :bucket=>"cloud-crawler", :path=>"crawl-pages", :pattern=>/40UTC/  }
# loader = CloudLoader::Loader.new(opts)
# p loader.first.first.keys
# # 
# loader.each do |chunk|
  # chunk.each do |json|
     # db << json.symbolize_keys
  # end
# end
# # for some reason, delimitters get replaced?

#  TODO  to finish
# 1.  -v --verbnose  -t --test  options
# 2. test basic scripts by hand
# 3. text mocks .. can i actually write and read n files
# 4. write spec tests with mocks
# 5. build the gem, make sure it is sane
# 6. check it in, with docs
# 7. add dependency to simple_search
# 8. modify xapian loader script to use s3 and/or local files
# 8.b  set up AWS ENV either with bunlder, or set on the command line with trollop via runner
# 9. add load file option, for redis loading
# 10.  add logging and exception handling

# document for later:
# 11. add timestamping, with some kind of cache, to only load moddified files? since last timestamp...
#   can check local files or some kind of file log => must maintain local log

#TODO:  consider replacing entirely with carrierwave
#  use for xapian loading / saving
#  might be able to integrate into s3 caches also

# 12. sync with redis-caches to make fog-cache, fog-loader or cloud-cache, cloud-loader
#  lets redis be ser/de-ser to/fro S3 storage
#  TODO:  Create a ~/.fog file as follows:  instead , in addition to .s3cmd  ??

# see also:  carrierwave, asset_pipeline



#  https://gist.github.com/bdunagan/1383301
#  multi-threader versions
#  https://github.com/SFEley/s3nuke/blob/original/s3nuke   4 years old

# access control issues
#  http://blog.zerosum.org/2011/03/02/better-aws-access-control-with-iam-and-fog.html

# warning # might have a max number of keys
#  https://groups.google.com/forum/#!topic/ruby-fog/s0umkU0ZGjo

#  see for the list all files
# https://groups.google.com/forum/#!searchin/ruby-fog/ruby$20fog$20list$20all$20files$20/ruby-fog/dlhTY_M4mf8/E83v_5SjsMMJ

