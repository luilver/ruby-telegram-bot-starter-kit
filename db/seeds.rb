# frozen_string_literal: true

User.delete_all
Link.delete_all

puts '== Inserting user'
User.create

puts '== Inserting links'
Link.create url: 'http://luilver.com'
