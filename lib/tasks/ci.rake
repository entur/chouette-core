namespace :ci do

  def database_name
    @database_name ||=
      begin
        config = YAML.load(ERB.new(File.read('config/database.yml')).result)
        config["test"]["database"]
      end
  end

  def parallel_tests?
    ENV["PARALLEL_TESTS"] == "true"
  end

  desc "Prepare CI build"
  task :setup do
    cp "config/database.yml", "config/database.yml.orig"
    cp "config/database/ci.yml", "config/database.yml"
    puts "Use #{database_name} database"

    if parallel_tests?
      sh "RAILS_ENV=test rake parallel:drop parallel:create parallel:migrate"
    else
      sh "RAILS_ENV=test rake db:drop db:create db:migrate"
    end
  end

  def git_branch
    if ENV['GIT_BRANCH'] =~ %r{/(.*)$}
      $1
    else
      `git rev-parse --abbrev-ref HEAD`.strip
    end
  end

  def deploy_envs
    Dir["config/deploy/*.rb"].map { |f| File.basename(f, ".rb") }
  end

  def deploy_env
    return ENV["DEPLOY_ENV"] if ENV["DEPLOY_ENV"]
    if git_branch == "master"
      "dev"
    elsif git_branch.in?(deploy_envs)
      git_branch
    end
  end

  desc "Check security aspects"
  task :check_security do
    sh "bundle exec bundle-audit check --update"
  end

  task :assets do
    sh "RAILS_ENV=test bundle exec rake assets:precompile i18n:js:export"
  end

  task :jest do
    sh "node_modules/.bin/jest" unless ENV["CHOUETTE_JEST_DISABLED"]
  end

  desc "Deploy after CI"
  task :deploy do
    unless ENV["CHOUETTE_DEPLOY_DISABLED"]
      if deploy_env
        sh "cap #{deploy_env} deploy:migrations deploy:seed"
      else
        puts "No deploy for branch #{git_branch}"
      end
    end
  end

  desc "Clean test files"
  task :clean do
    sh "rm -rf log/test.log"
    sh "RAILS_ENV=test bundle exec rake assets:clobber"
  end

  task :spec do
    if parallel_tests?
      # parallel tasks invokes this task ..
      # but development db isn't available during ci tasks
      Rake::Task["db:abort_if_pending_migrations"].clear

      Rake::Task["parallel:spec"].invoke
    else
      Rake::Task["spec"].invoke
    end
  end

  task :build => ["ci:setup", "ci:assets", "ci:spec", "ci:jest", "cucumber", "ci:check_security"]

  namespace :docker do
    task :clean do
      puts "Drop #{database_name} database"
      if parallel_tests?
        sh "RAILS_ENV=test rake parallel:drop"
      else
        sh "RAILS_ENV=test rake db:drop"
      end

      # Restore projet config/database.yml
      # cp "config/database.yml.orig", "config/database.yml" if File.exists?("config/database.yml.orig")
    end
  end

  task :docker => ["ci:build"]
end

desc "Run continuous integration tasks (spec, ...)"
task :ci => ["ci:build", "ci:deploy", "ci:clean"]
