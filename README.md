![GitStars Screenshot](https://raw.github.com/prashantrajan/gitstars-oss/master/app/assets/images/gitstars_screenshot_full_v2.png)


Development
============

* Copy config/database.yml.example to config/database.yml and edit for your environment

* `bundle install`

* `bundle exec rake db:migrate`

* `foreman start` (will run a unicorn server at http://localhost:5000)

* RSpec suite: `bundle exec rake spec`


Hosting on Heroku
=================

The app was hosted on Heroku with a `heroku-postgresql:basic` database (see: [Heroku Postgres](https://addons.heroku.com/heroku-postgresql))

Addons
------

* [Memcache](https://addons.heroku.com/memcache)

* [Sendgrid](https://addons.heroku.com/sendgrid)

* [New Relic](https://addons.heroku.com/newrelic)

* [Heroku Scheduler](https://addons.heroku.com/scheduler) - `bundle exec rake scheduler:repo_set_tag_list`


IMPORTANT
=========

* Search and replace CHANGEME within codebase
