require "fileutils"
require "git"
require "logger"

REPO_DIR = "tmp/kitchen-docs"
DOC_DIR  = "source/docs"

LAST_COMMIT_MSG_FILE = "tmp/last_commit_message"

$stdout.sync = true

task :default => [:update_docs]
task :publish => [:pull, :update_docs, :commit, :push]

task :pull do
  git = Git.open(Dir.pwd, :log => Logger.new(STDOUT))
  git.pull
end

task :update_docs do
  puts "Cleaning up #{REPO_DIR}"
  FileUtils.rm_rf(REPO_DIR)

  puts "Cleaning up #{DOC_DIR}"
  FileUtils.rm_rf(DOC_DIR)

  puts "Cloning Kitchen Docs repository ..."
  git = Git.clone("https://github.com/test-kitchen/kitchen-docs.git", REPO_DIR)

  File.open(LAST_COMMIT_MSG_FILE, "wb") do |file|
    file.write(git.log.first.message)
  end

  puts "Copying Kitchen Docs ..."
  FileUtils.cp_r(File.join(REPO_DIR, DOC_DIR), DOC_DIR)

  puts "Cleaning up #{REPO_DIR}"
  FileUtils.rm_rf(REPO_DIR)
end

task :commit do
  message = "automated commit"
  if File.exists?(LAST_COMMIT_MSG_FILE)
    message = File.open(LAST_COMMIT_MSG_FILE, "r").read
  end
  git = Git.open(Dir.pwd, :log => Logger.new(STDOUT))
  git.add
  git.commit(message)
end

task :push do
  git = Git.open(Dir.pwd, :log => Logger.new(STDOUT))
  git.push
  git.push(git.remote("heroku"))
end

namespace :assets do
  task :precompile do
    sh "middleman build --clean --verbose"
  end
end
