# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{qa_release_tasks}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jason Noble", "Rein Henrichs"]
  s.autorequire = %q{qa_release_tasks}
  s.date = %q{2009-03-31}
  s.description = %q{A gem that provides workflow driven rake tasks for git QA branch management}
  s.extra_rdoc_files = ["README", "LICENSE"]
  s.files = ["LICENSE", "README", "Rakefile", "lib/cli.rb", "lib/git", "lib/git/commands.rb", "lib/git/release_notes.rb", "lib/git/tagger.rb", "lib/qa_release_tasks.rb", "lib/tasks", "lib/tasks/qa_release.rake", "lib/tasks/qa_release.rb", "spec/qa_release_tasks_spec.rb", "spec/spec_helper.rb"]
  s.has_rdoc = true
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A gem that provides workflow driven rake tasks for git QA branch management}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
