class UpdateTaggingData < ActiveRecord::Migration
  def change
    ActsAsTaggableOn::Tagging.update_all(context: 'tags')
  end
end
