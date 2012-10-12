# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)


# Tags
["ActionScript", "Arduino", "C", "Clojure", "CoffeeScript", "Common Lisp", "Dart", "Elixir", "Erlang",
 "Go", "Groovy", "Haskell", "Java", "JavaScript", "Lua", "OCaml", "Objective-C", "Objective-J", "PHP", "Perl",
 "Puppet", "Python", "R", "Ruby", "Scala", "Shell", "Smalltalk", "Visual Basic"].each do |name|
  Tag.where(:name => name).first_or_create
end

Tag.where(:name => 'C++').first_or_create(:slug => 'c++')
Tag.where(:name => 'C#').first_or_create(:slug => 'c#')
Tag.where(:name => 'F#').first_or_create(:slug => 'f#')
