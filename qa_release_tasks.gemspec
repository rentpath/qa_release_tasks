# -*- encoding: utf-8 -*-
require File.expand_path('../lib/qa_release_tasks/version', __FILE__)

Gem::Specification.new do |s|
  s.name = "qa_release_tasks"
  s.version = QaReleaseTasks::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jason Noble", "Rein Henrichs"]
  s.autorequire = "qa_release_tasks"
  s.date = "2013-12-12"
  s.description = "A gem that provides workflow driven rake tasks for git QA branch management"
  s.executables = ["git-changelog"]
  s.extra_rdoc_files = ["README", "LICENSE"]
  s.files = `git ls-files`.split("\n")
  s.homepage = ""
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "A gem that provides workflow driven rake tasks for git QA branch management"

  s.add_runtime_dependency(%q<pivotal-tracker>, [">= 0"])
  s.add_runtime_dependency(%q<mediawiki-gateway>, ["= 0.6.2"])
  s.add_development_dependency('rake', '~> 10.4', '>= 10.0')
  s.add_development_dependency('rspec', '~> 3.2', '>= 3.0.0')
  s.add_development_dependency('primedia', '~> 0')
end
