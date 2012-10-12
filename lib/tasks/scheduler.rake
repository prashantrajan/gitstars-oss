namespace :scheduler do

  desc 'Set the tag list for repos'
  task :repo_set_tag_list => :environment do
    puts 'Calling Repo#set_tag_list'
    Repo.set_tag_list
  end

end
