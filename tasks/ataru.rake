namespace :ataru do
  desc 'Check if the code snippets in our markdown files are working as expected'
  task :check do
    system('bundle exec ataru check') || exit(1)
  end
end
