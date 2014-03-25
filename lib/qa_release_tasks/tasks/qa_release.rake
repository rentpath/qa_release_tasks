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

    desc "Generate release notes for a given tag in wiki format"
    task :wiki do
      Git::Wiki.new.annotate!
    end

    desc "Update the wiki with release notes for a given tag"
    task :wiki_update do
      Git::Wiki.new.annotate!(true)
    end
  end
end
