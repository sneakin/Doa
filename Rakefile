require 'spec/rake/spectask'

task :default => [ :spec, :rdoc ]

desc "Run all specs in the spec directory"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = [ '--options', File.join(File.dirname(__FILE__), "spec", "spec.opts") ]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

require 'rake/rdoctask'

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_files.add("README.rdoc", "lib/**/*.rb")
  rdoc.main = 'README.rdoc'
  rdoc.title = 'Doa'
  rdoc.rdoc_dir = 'doc/api'
  rdoc.options << '--line-numbers' << '--inline-source'
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "Doa"
    gemspec.summary = "The Tester"
    gemspec.description = "rSpec controller macros"
    gemspec.email = "suppert@semanticgap.com"
    gemspec.homepage = "http://github.com/sneakin/Doa"
    gemspec.authors = [ "Nolan Eakins <sneakin@semanticgap.com>" ]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
