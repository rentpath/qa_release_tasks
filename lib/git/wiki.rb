module Git
  class Wiki
    require 'date'
    require 'erb'
    require 'enumerator'
    include CLI
    include Commands
    require 'media_wiki'
    require 'pivotal-tracker'
    require 'yaml'

    attr_reader :options
    def initialize(options = {})
      @options = options
      assert_is_git_repo
      initialize_pivotal
      initialize_wiki
    end

    def annotate!(update_wiki_flag=false)
      tags = get_tag_options
      error "No version tags available." if tags.empty?

      if update_wiki_flag
        @release_list = @wiki_config[:release_list]
        username = options[:username] || ask("Wiki username?")
        system "stty -echo"
        password = options[:password] || ask("Wiki password?")
        system "stty echo"
        puts
        @wiki.login(username, password, @wiki_config[:auth_domain])
        assert_wiki_release_list_page_exists

        release_date = options[:date] || Date.parse(ask("Release date?", Date.today.strftime))

        release_page_id = wiki_full_release_page_id(@release_list, release_date)
        if wiki_page_exists?(release_page_id)
          exit 1 if ask("Release page #{release_page_id} already exists.  Overwrite? [yn]", default=nil, valid_response=['y', 'n']) == 'n'
        end
      end

      if options[:all]
        start_index = 0
        end_index = tags.length - 1
      else
        start_tag = options[:from] || ask("Start at which tag?", tags[0], tags)
        start_index = tags.index(start_tag)
        end_tag = options[:to] || ask("End at which tag?", tags[start_index + 1] || tags[start_index], tags)
        end_index = tags.index(end_tag) # include end tag
      end

      @release_version = tags[start_index]
      @prior_version = tags[end_index]
      @release_details = release_details_table(@release_version, @prior_version)

      if update_wiki_flag
        @dotted_date = dotted_date(release_date)
        release_page_content = render_template
        update_wiki(release_page_content, @release_list, release_date)
      else
        puts @release_details
      end
    end

    def get_tag_options
      get_tags.reverse
    end

    def render_template
      template.result(binding)
    end

    def template
      filename = template_filename
      erb = ERB.new(File.read(filename))
      erb.filename = filename
      erb
    end

    def template_filename
      "#{File.dirname(__FILE__)}/../../etc/release_template.erb"
    end

    def dotted_date(date)
      date.strftime('%Y.%m.%d')
    end

    def us_slash_date(date)
      date.strftime('%m/%d/%Y')
    end

    def release_details_table(start, finish)
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
          stories[0][log_line].merge!({:red => true})
        end
      end

      result = table_start
      Struct.new("UnknownStory", :id, :name, :story_type, :url)
      stories.each do |story_id, commits|
        story = @pivotal.stories.find(story_id) || Struct::UnknownStory.new(story_id, 'No Pivotal Story Available', 'Unknown', nil)

        row = "|-\n| "
        row += story.url ? "[#{story.url} #{story.id}]" : "#{story.id}"
        row += "\n| #{story.name}\n| #{story.story_type.capitalize}\n|\n{|\n"
        commits.each do |commit, details|
          row += "|-#{'style="background-color:#ffcccc;"' if details[:red]}\n| [http://github.com/primedia/#{project_name}/commit/#{commit} #{commit}]\n| #{details[:pair]}\n| #{details[:message]}\n"
        end
        row += "|}\n"

        result << row
      end
      result << table_end
    end

    def update_wiki(release_page_content, release_list, release_date)
      release_page_id = wiki_full_release_page_id(release_list, release_date)
      wiki_page_edit!(release_page_id, release_page_content)
      puts "Wrote release page: #{wiki_view_url(release_page_id)}"
      list_content = wiki_page_content(release_list)
      insert_link_in_list_content!(list_content, release_page_id, release_date)
      wiki_page_edit!(release_list, list_content)
      puts "Updated list page:  #{wiki_view_url(release_list)}"
    end

    def wiki_full_release_page_id(release_list, release_date)
      date_id = wiki_id_date(release_date)
      wiki_full_page_id(release_list, date_id)
    end

    def wiki_id_date(date)
      date.strftime('%Y%m%d')
    end

    def wiki_full_page_id(release_list, date_id)
      "#{release_list}/#{date_id}"
    end

    def wiki_view_url(path=nil)
      url = @wiki_config[:view_url]
      url = "#{url}/#{path}" if path
      url
    end

    def insert_link_in_list_content!(content, release_page_id, release_date)
      link_markup = "*[[#{release_page_id} |#{us_slash_date(release_date)}]]\n"
      insertion_index = content.index(/^\*/) or 0
      content.insert(insertion_index, link_markup)
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
      PivotalTracker::Client.use_ssl = true
      PivotalTracker::Client.token = config['token']
      @pivotal = PivotalTracker::Project.find(config['project'])
    end

    def initialize_wiki
      release_list = nil
      if File.exists?('config/wiki.yml')
        config = YAML.load_file("config/wiki.yml")
        release_list = config['release_list']
      end
      unless release_list
        puts "You need to create config/wiki.yml with the following contents:"
        puts "\trelease_list: _____WIKI RELEASE LIST PAGE______"
        puts "\nFor example:\n\trelease_list: IDG/Releases/Web/ApartmentGuide"
        exit
      end
      @wiki_config = {
        api_url: 'http://wiki/api.php',
        view_url: 'http://wiki/index.php',
        auth_domain: 'PRM',
        release_list: release_list
      }
      @wiki = MediaWiki::Gateway.new(@wiki_config[:api_url])
    end

    def table_start
      <<'EOF'
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
      "|}"
    end

    def wiki_release_list_page
      @wiki_config[:release_list]
    end

    def wiki_page_exists?(path)
      ! wiki_page_content(path).nil?
    end

    def wiki_page_content(path)
      @wiki.get(path)
    end

    def wiki_page_edit!(path, content)
      @wiki.edit(path, content)
    end

    def assert_wiki_release_list_page_exists
      error "Release listing wiki page doesn't exist: #{wiki_release_list_page}" unless wiki_page_exists?(wiki_release_list_page)
    end

  end
end
