# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "qa_release_tasks"
  s.version = "1.4.0a"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jason Noble", "Rein Henrichs"]
  s.autorequire = "qa_release_tasks"
  s.date = "2013-10-23"
  s.description = "A gem that provides workflow driven rake tasks for git QA branch management"
  s.executables = ["git-changelog"]
  s.extra_rdoc_files = ["README", "LICENSE"]
  s.files = ["LICENSE", "README", "Rakefile", "bin/git-changelog", "etc/release_template.erb", "lib/cli.rb", "lib/git", "lib/git/commands.rb", "lib/git/release_notes.rb", "lib/git/tagger.rb", "lib/git/wiki.rb", "lib/qa", "lib/qa/server", "lib/qa/server/views", "lib/qa/server/views/layout.html.erb", "lib/qa/server/views/wiki_form.html.erb", "lib/qa/server.rb", "lib/qa.rb", "lib/qa_release_tasks.rb", "lib/tasks", "lib/tasks/qa_release.rake", "lib/tasks/qa_release.rb", "spec/qa_release_tasks_spec.rb", "spec/spec_helper.rb"]
  s.homepage = ""
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "A gem that provides workflow driven rake tasks for git QA branch management"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<pivotal-tracker>, [">= 0"])
    else
      s.add_dependency(%q<pivotal-tracker>, [">= 0"])
    end
  else
    s.add_dependency(%q<pivotal-tracker>, [">= 0"])
  end
end
