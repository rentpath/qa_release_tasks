module Git
  class Wiki
    require 'enumerator'
    include CLI
    include Commands
    require 'pivotal-tracker'
    require 'yaml'
    
    attr_reader :options
    def initialize(options = {})
      @options = options
    end

    def annotate!
      assert_is_git_repo
      initialize_pivotal
      tags = get_tags.reverse
      error "No version tags available." if tags.empty?
      
      if options[:all]
        start_index = 0
        end_index = tags.length - 1
      else
        start_tag = options[:from] || ask("Start at which tag?", tags[0], tags)
        start_index = tags.index(start_tag)   
        end_tag = options[:to] || ask("End at which tag?", tags[start_index + 1] || tags[start_index], tags)
        end_index = tags.index(end_tag) + 1 # include end tag
      end
      
      start = tags[start_index]
      finish = tags[end_index]
      range = ''
      range << "refs/tags/#{finish}.." if finish # log until end tag if there is an end tag
      range << "refs/tags/#{start}"
      log = `git log --no-merges --pretty=format:"%h  %s" #{range}`.strip.split("\n")
      project_name = `pwd`.chomp.split('/').last
      # stories = { 12345 => { 'abc123' => "foo", 'def343' => "bar" } }
      stories = Hash.new{|hash, key| hash[key] = {}}
      log.each do |log_line|
        # (commit, pair, pivotal, subject) = log_line.split(/\s+/, 4)
        #[(.+?)]\s*[(\d+)](.+)
        (match, commit, pair, pivotal, subject) = *log_line.match(/(.+?)\s*\[([a-zA-Z\/]{2,})\]\s*\[\#?([\d\/]+)\](.*)/)
        if match
          if commit.gsub!(/\s*Revert.*/, '')
            subject = subject + ' [REVERT]'
          end
          pivotal.split('/').each do |p|
            stories[p.to_i][commit] = { :pair => pair, :message => subject.gsub("\"", '').strip }
          end
        else
          stories[0][log_line] = {:pair => '', :message => log_line}
        end
      end
      deploy_log = `git log --no-merges --pretty=format:"%h  %s" #{range} config Capfile`.strip.split("\n")
      project_name = `pwd`.chomp.split('/').last
      deploy_log.each do |log_line|
        # (commit, pair, pivotal, subject) = log_line.split(/\s+/, 4)
        #[(.+?)]\s*[(\d+)](.+)
        (match, commit, pair, pivotal, subject) = *log_line.match(/(.+?)\s*\[([a-zA-Z\/]{2,})\]\s*\[\#?([\d\/]+)\](.*)/)
        if match
          commit.gsub!(/\s*Revert.*/, '')
          pivotal.split('/').each do |p|
            stories[p.to_i][commit].merge!({:red => true})
          end
        else
          stories[0][commit].merge!({:red => true})
        end
      end
      
      
      table_start
      Struct.new("UnknownStory", :id, :name, :story_type, :url)
      stories.each do |story_id, commits|
        story = @pivotal.stories.find(story_id) || Struct::UnknownStory.new(story_id, 'No Pivotal Story Available', 'Unknown', nil)

        row = "|-\n| "
        row += story.url ? "[#{story.url} #{story.id}]" : "#{story.id}"
        row += "\n| #{story.name}\n| #{story.story_type.capitalize}\n|\n{|\n"
        commits.each do |commit, details|
          row += "|-#{'style="background-color:#ffcccc;"' if details[:red]}\n| [http://github.com/primedia/#{project_name}/commit/#{commit} #{commit}]\n| #{details[:pair]}\n| #{details[:message]}\n"
        end
        row += "|}"
        
        puts row
      end
      table_end
      puts
    end
    
    private
    
    def initialize_pivotal
      if File.exists?('config/pivotal.yml')
        config = YAML.load_file("config/pivotal.yml")
      end
      if !File.exists?('config/pivotal.yml') || config.nil? || config['token'].nil? || config['project'].nil?
        puts "You need to create config/pivotal.yml with the following contents:"
        puts "\ttoken: _____PIVOTAL TOKEN ID____________"
        puts "\tproject: _______ PIVOTAL PROJECT ID _______"
        exit
      end
      
      PivotalTracker::Client.token = config['token']
      @pivotal = PivotalTracker::Project.find(config['project'])
    end
    def table_start
      puts <<'EOF'
{| border="1"
|+Release Contents
! Pivotal #
! User Story
! Story Type
! Git Commits
|-
EOF
    end
    def table_end
      puts "|}"
    end
  end
end
