require "fileutils"
require "git"
require "logger"

task :default => [:update_docs]
task :publish => [:pull, :update_docs, :commit, :push]

task :pull do
  git = Git.open(Dir.pwd, :log => Logger.new(STDOUT))
  git.pull
end

task :update_docs do
  repo_dir = "tmp/kitchen-docs"
  doc_dir  = "source/docs"

  puts "Cleaning up #{repo_dir}"
  FileUtils.rm_rf(repo_dir)

  puts "Cleaning up #{doc_dir}"
  FileUtils.rm_rf(doc_dir)

  puts "Cloning Kitchen Docs repository ..."
  Git.clone("https://github.com/test-kitchen/kitchen-docs.git", repo_dir)

  puts "Copying Kitchen Docs ..."
  FileUtils.cp_r(File.join(repo_dir, doc_dir), doc_dir)

  puts "Cleaning up #{repo_dir}"
  FileUtils.rm_rf(repo_dir)
end

task :commit do
  git = Git.open(Dir.pwd, :log => Logger.new(STDOUT))
  git.add
  git.commit("automated commit")
end

task :push do
  git = Git.open(Dir.pwd, :log => Logger.new(STDOUT))
  git.push
  git.push(git.remote("heroku"))
end
