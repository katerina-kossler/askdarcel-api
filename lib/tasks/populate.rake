namespace :db do
  desc 'Erase and fill a development database'
  task populate: :environment do
    unless Rails.env.development?
      puts 'db:populate task can only be run in development.'
      exit
    end

    require 'faker/sheltertech'

    [Note, ScheduleDay, Schedule, Phone, Address, Category, Service, Resource].each(&:delete_all)

    category_names = %w(Shelter Food Medical Hygiene Technology Money)
    category_image_paths = %w(ic-housing@3x.png ic-food@3x.png
                              ic-health@3x.png ic-hygiene@3x.png ic-work@3x.png ic-money@3x.png)

    6.times do |i|
      FactoryGirl.create(:category, name: category_names[i], image_path: category_image_paths[i])
    end

    categories = Category.all

    128.times do
      name = Faker::Company.name
      short_description = Faker::Lorem.sentence if rand(2) == 0
      long_description = Faker::ShelterTech.description
      website = Faker::Internet.url if rand(2) == 0
      services = []
      (rand(2) + 1).times do
        services.push(FactoryGirl.create(:service,
                                         long_description: Faker::ShelterTech.description))

        FactoryGirl.create(:resource,
                           name: name,
                           short_description: short_description,
                           long_description: long_description,
                           website: website,
                           categories: categories.sample(rand(4)),
                           services: services)
      end
    end
  end
end