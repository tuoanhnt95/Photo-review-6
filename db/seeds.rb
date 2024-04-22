# frozen_string_literal: true

# Run: rails db:seed
Rails.logger.debug 'Removing old data...'
Rails.logger.debug 'Removing photoUserReview data...'
PhotoUserReview.destroy_all
Rails.logger.debug 'Removing photo data...'
Photo.destroy_all
Rails.logger.debug 'Removing album data...'
Album.destroy_all
Rails.logger.debug 'Removing user data...'
User.destroy_all
Rails.logger.debug 'Removing review data...'
Review.destroy_all
Rails.logger.debug 'Removing upload data...'
Upload.destroy_all
Rails.logger.debug 'Removing user data...'
User.destroy_all

#-----------------# Create new data #-----------------#
Rails.logger.debug 'Creating new data...'
Rails.logger.debug 'Creating review data...'
Review.create([
                { name: 'No', value: 0 },
                { name: 'Maybe', value: 2 },
                { name: 'Yes', value: 1 }
              ])
Rails.logger.debug 'Creating user data...'
User.create([
              {
                email: 'test1@gmail.com',
                password: '123123'
              },
              {
                email: 'test2@gmail.com',
                password: '123123'
              }
            ])
Rails.logger.debug { "#{User.count} users created. User info: #{User.first}" }

Rails.logger.debug 'Creating album data...'
Album.create([
               {
                 name: 'Oanh work profile 2023',
                 expiry_date: '2023-07-20',
                 user_id: User.first.id
               },
               {
                 name: 'Song artsy 2023',
                 expiry_date: '2023-07-10',
                 user_id: User.first.id
               },
               {
                 name: 'Arisa smile 2022',
                 expiry_date: '2022-07-15',
                 user_id: User.first.id
               }
             ])
Rails.logger.debug { "#{Album.count} albums created." }

Rails.logger.debug 'Creating photo data...'
Photo.create([
               {
                 name: 'Nikon-D3500-Shotkit-2',
                 image: 't7rmnsrnhlqhjhlqpo6y',
                 angle: 0,
                 album_id: Album.first.id
               },
               {
                 name: 'Sony-a6000-Shotkit',
                 image: 'rmsuqgcmfkqm6vfetfd0',
                 angle: 0,
                 album_id: Album.all[1].id
               },
               {
                 name: 'Fuijifilm-XH1-Shotkit',
                 image: 'bfvvvdvmazvayfepwmr1',
                 angle: 0,
                 album_id: Album.all[2].id
               }
             ])
Rails.logger.debug { "#{Photo.count} photos created." }
Rails.logger.debug 'Finished seeding!'
