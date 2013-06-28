cloud_loader
============
Loads files from s3 (or any Fog::Storage platform)
Retrives a list of files, specified by a file matching pattern
Copies file to tmp space

Optional:
 provides iterates over gzipped content / lines in file 
 supports JSON, converts each line to with symbolized keys
 
Loader.chunks(/pat/).each do |chunk|
  chunk.each_line
  chunk.each_json
  chunk.each_hash  
  chunk.each_record
end

Eventually the code will manage migrations
so that it can update from a list of files,
but not re-iterate files that have already been loaded

 