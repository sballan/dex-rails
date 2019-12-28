# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
[
  Index::Page.create(url_string: 'https://harrypotter.fandom.com/wiki/Main_Page'),
  Index::Page.create(url_string: 'https://en.wikipedia.org/wiki/Star_Wars'),
  Index::Page.create(url_string: 'https://soundcloud.com/vulfpeck'),
  Index::Page.create(url_string: 'https://www.starwars.com/community'),
  Index::Page.create(url_string: 'https://fanlore.org/wiki/His_Dark_Materials')
]
