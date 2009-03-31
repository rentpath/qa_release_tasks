module Git
  class ReleaseNotes
    require 'enumerator'
    include CLI
    include Commands

    def annotate!
      tags = get_tags.reverse

      start_tag = ask "Start at which tag?", tags[0], tags
      end_tag = ask "End at which tag?", tags[1], tags
      end_index = tags.index(end_tag) + 1 # include end tag
      start_index = tags.index(start_tag)
      puts

      tags[start_index..end_index].each_cons(2) do |start, finish|
        log = `git log --pretty=format:"%h  %s" refs/tags/#{finish}..refs/tags/#{start}`.strip
        next if log.empty?
        puts "#{start}"
        puts "=" * start.length
        puts log.split("\n").reject{|line| line.include?("Merge branch 'master' into qa_branch")}
        puts
      end
    end
  end
end