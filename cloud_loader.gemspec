spec = Gem::Specification.new do |s|
  s.name = "cloud_loader"
  s.version = "0.1"
  s.author = "Charles H. Martin, PhD"
  s.homepage    = "http://github.com/CalculatedContent/cloud_loader"
  s.rubyforge_project = "cloud_loader"
  s.platform = Gem::Platform::RUBY
  s.summary     = "Iterator over a large chunk of files on s3 or fog"
  s.require_path = "lib"

  s.add_dependency "fog"

  s.add_development_dependency "rake", ">=10.0.0"
  s.add_development_dependency "rspec", ">=2.12.0"



  s.files = %w[
    LICENSE.txt
    README.rdoc
    Rakefile
  ] + Dir['lib/**/*.rb']

  s.test_files = Dir['spec/*.rb']
end
