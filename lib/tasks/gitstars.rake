namespace :gitstars do

  desc 'Preseed given login name - rake gitstars:preseed_user[username]'
  task :preseed_user, [:login] => :environment do |t, args|
    User.pre_seed(args[:login])
  end

end


