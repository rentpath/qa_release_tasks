namespace :qa do
  namespace :release do
    desc "Create a new minor version release from master."
    task :new do
      Git::Tagger.new(:minor => true, :update => true).tag!
    end

    desc "Create a new point version release from qa branch."
    task :update do
      Git::Tagger.new(:point => true).tag!
    end

    desc "Add release notes for a given tag based on commit summaries"
    task :notes do
      Git::ReleaseNotes.new.annotate!
    end
  end
end
