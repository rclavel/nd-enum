# frozen_string_literal: true

require_relative 'lib/nd/enum/version'

Gem::Specification.new do |spec|
  spec.name = 'nd-enum'
  spec.version = ND::Enum::VERSION
  spec.authors = ['Romain Clavel']
  spec.email = ['romain@clavel.io']

  spec.summary = 'Powerful enum for Rails models.'
  spec.homepage = 'https://github.com/rclavel/nd-enum'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/rclavel/nd-enum'
  spec.metadata['changelog_uri'] = 'https://github.com/rclavel/nd-enum/blob/master/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  spec.add_dependency 'activesupport', '>= 6.0.0'
  spec.add_dependency 'activerecord',  '>= 6.0.0'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
