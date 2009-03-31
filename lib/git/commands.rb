module Git
  module Commands
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
      %x{git tag}.split.grep(version_regexp).sort_by{|v| v.split('.').map{|nbr| nbr[/\d+/].to_i}}
    end

    def next_version(options={})
      latest_tag = get_tags.last.strip
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

    #  based on 'git status' output, does this repo contain changes that need to be committed?
    #  optional second argument is a specific file (or directory) in the repo.
    def needs_commit?(dir = Dir.pwd, file = nil)
      rval = false
      Dir.chdir(dir) do
        status = %x{git status}
        if file.nil?
          rval = true unless status =~ /nothing to commit \(working directory clean\)|nothing added to commit but untracked files present/
          if status =~ /nothing added to commit but untracked files present/
            warn "untracked files present in #{dir}"
            show_changed_files(status)
          end
        else
          rval = true if status =~ /^#\t.*modified:   #{file}/
        end
      end
      rval
    end

    def warn(message)
      STDERR.puts "*" * 50
      STDERR.puts "Warning: #{message}"
      STDERR.puts "*" * 50
    end

    def error(message)
      STDERR.puts "*" * 50
      STDERR.puts "Error: #{message}"
      STDERR.puts "*" * 50
      exit 1
    end
  end
end
