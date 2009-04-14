module Git
  class Tagger
    include CLI
    include Commands

    attr_reader :options
    def initialize(options)
      @options = options
    end

    def tag!
      assert_is_git_repo
      begin
        assert_on_qa_branch
        assert_no_local_modifications
        update_qa if options[:update]
        fetch_tags
        tag_next_version(options)
        push_tags
      ensure
        system 'git checkout qa_branch' unless get_branch == 'qa_branch'
      end
    end

    private
    
    def fetch_tags
      system("git fetch --tags")
    end

    def assert_no_local_modifications
      if needs_commit?
        error "You have local modifications.  Use git commit or git stash to fix that."
      end
    end

    def assert_on_qa_branch
      unless get_branch == 'qa_branch'
        error "You have to be in the qa_branch to do a release."
      end
    end

    def update_qa
      verify_update_is_ok
      system("git checkout master")    &&
      system("git pull --rebase")      &&
      system("git checkout qa_branch") &&
      system("git pull --rebase")      &&
      response = %x(git merge master)

      unless $?.success?
        `git reset --hard`
        error <<-EOS
        Conflicts when updating the QA branch from master prevented a release from being created.
        Please resolve these conflicts and then re-run rake qa:release:new.
        EOS
      else
        system("git push")
      end

      unless response.include?("Fast forward") || response.include?('Already up-to-date.')
        warn "There are outstanding changes in qa_branch that may need to be merged into master"
      end
    end
    
    def verify_update_is_ok
      wrap do
        answer = ask "This will pull the latest changes from master into the qa_branch. Continue?",
            nil, /^yes|no$/i, "You must enter either 'yes' or 'no'"
        abort "Exiting" unless answer.match(/^yes$/i)
      end
    end

    def tag_next_version(options={})
      tag = next_version(options)
      if options[:update]
        invalid_message = "Invalid version. Version must be in the format: \"v1.2.3\""
        tag = ask "Name of new version tag ", tag, valid_version_regexp, invalid_message
      end
      system "git tag #{tag}"
    end

    def push_tags
      system "git push --tags"
    end
  end
end
