$:.unshift(File.dirname(__FILE__))
require 'spec_helper'
require 'cloud_loader/version'
require 'cloud_loader/chunks'

module CloudLoader
  describe  CloudLoader::Chunks  do
    

    before(:each) do
      # connect to fog / s3 ... not mocked yet
    end

    after(:each) do
      # fog dissconnect
    end
    
    

 end    
end