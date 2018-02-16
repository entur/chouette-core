namespace :ci do
  desc "Prepare CI build"
  task :setup do
    cp "config/database/jenkins.yml", "config/database.yml"
    sh "RAILS_ENV=test rake db:drop db:create db:migrate"
    sh "yarn --no-progress install"
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
    sh "RAILS_ENV=test bundle exec rake assets:precompile"
  end

  task :i18n_js_export do
    sh "RAILS_ENV=test bundle exec rake i18n:js:export"
  end

  task :jest do
    sh "node_modules/.bin/jest" unless ENV["CHOUETTE_JEST_DISABLED"]
  end

  desc "Deploy after CI"
  task :deploy do
    return if ENV["CHOUETTE_DEPLOY_DISABLED"]

    if deploy_env
      sh "cap #{deploy_env} deploy:migrations"
    else
      puts "No deploy for branch #{git_branch}"
    end
  end

  desc "Clean test files"
  task :clean do
    sh "rm -rf log/test.log"
    sh "RAILS_ENV=test bundle exec rake assets:clobber"
  end
end

desc "Run continuous integration tasks (spec, ...)"
task :ci => ["ci:setup", "ci:assets", "ci:i18n_js_export", "spec", "ci:jest", "cucumber", "ci:check_security", "ci:deploy", "ci:clean"]
