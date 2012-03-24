Gem::Specification.new do |spec|
  paths = %w{lib}
  spec.name = "cabin-web"
  spec.version = "0.0.1"
  spec.summary = "Web interface on cabin"
  spec.description = spec.summary
  spec.license = "Apache License (2.0)"
  spec.authors = ["Jordan Sissel"]
  spec.email = ["jls@semicomplete.com"]
  spec.homepage = "https://github.com/jordansissel/ruby-cabin-web"

  spec.add_dependency("cabin", "~> 0.4.4")
  spec.add_dependency("json")
  spec.add_dependency("sinatra")
  spec.add_dependency("ftw", "~> 0.0.11")
  spec.add_dependency("haml")

  spec.require_paths << "lib"
  spec.bindir = "bin"

  files = []
  paths.each do |path|
    if File.file?(path)
      files << path
    else
      files += Dir["#{path}/**/*"]
    end
  end

  spec.files = files
end

