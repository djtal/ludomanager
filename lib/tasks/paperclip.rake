namespace :paperclip do
  desc "Recreate attachments and save them to new destination"
  task :move_attachments => :environment do

    Game.find_each do |game|
      unless game.box_file_name.blank?
        filename = Rails.root.join('public', 'system', 'boxes', game.id.to_s, 'original', game.box_file_name)

        if File.exists? filename
          puts "Re-saving image attachment #{game.id} - #{filename}"
          image = File.new filename
          game.box = image
          game.save
          # if there are multiple styles, you want to recreate them :
          game.box.reprocess!
          image.close
        end
      end
    end
  end
end
