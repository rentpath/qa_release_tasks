module Git
  module Commands

    def assert_is_git_repo
      error "Not a git repository" unless is_git_repo?
    end

    def is_git_repo?
      File.directory?('.git')
    end

    def repo_name
      File.basename(Dir.pwd)
    end

    #  figure out what branch the pwd's repo is on
    def get_branch
      match = Regexp.new("^# On branch (.*)").match(`git status`)
      match && match[1]
    end
    
     # e.g. v1.4.3
    def valid_version_regexp
      /^v\d+\.\d+\.\d+/
    end

    # Find all version tags
    def get_tags
      version_regexp = valid_version_regexp
      %x{git tag}.split.grep(version_regexp).sort_by{|v| v.split('.').map{|nbr| nbr[/\d+/].to_i}}.map{|tag| tag.strip}
    end

    def next_version(options={})
      latest_tag = get_tags.last
      return 'v0.0.1' unless latest_tag

      unless latest_tag.match valid_version_regexp
        warn "invalid version number"
        return latest_tag
      end

      major, minor, point = latest_tag.split('.')
      major = major[1..-1]
      if options[:major]
        major.succ!
        minor, point = '0', '0'
      elsif options[:minor]
        minor.succ!
        point = '0'
      elsif options[:point]
        point.succ!
      else
        warn "unable to increment version number."
      end

      'v' + [major, minor, point].join('.')
    end
  end
end
