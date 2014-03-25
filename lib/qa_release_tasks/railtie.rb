module QaReleaseTasks
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'qa_release_tasks/tasks/qa_release.rake'
    end
  end
end
