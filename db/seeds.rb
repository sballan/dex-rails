# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Page.create(url_string: 'https://harrypotter.fandom.com/wiki/Main_Page')
Page.create(url_string: 'https://en.wikipedia.org/wiki/Star_Wars')
Page.create(url_string: 'https://soundcloud.com/vulfpeck')
Page.create(url_string: 'https://www.starwars.com/community')
Page.create(url_string: 'https://fanlore.org/wiki/His_Dark_Materials')

