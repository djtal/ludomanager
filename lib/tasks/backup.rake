require 'aws-sdk'

namespace :ludomanager do
  namespace :backup do
    include FileUtils

    desc "Backs up the MySQL database to a timestamped file"
    task :database do
      now = Time.now
      basename = "#{ENV['DATABASE_NAME']}_mysql_#{now.strftime('%Y%m%d%H%M')}.sql.gz"
      filename = File.join(get_backup_path, basename)
      password = ENV['DATABASE_PWD']? %( -p"#{ENV['DATABASE_PWD']}") : ''
      system %(mysqldump -q --opt -u "#{ENV['DATABASE_USER']}"#{password} "#{ENV['DATABASE_NAME']}" | gzip --force > "#{filename}")
      upload_to_s3(filename, :keep_local => false)
    end

    desc "Backup upload files"
    task :images do
      now = Time.now
      basename = "ludomanager_images.tar.gz"
      filename = File.join(get_backup_path, basename)
      system %(tar czhf #{filename} -C #{Rails.root.join('public/system')} .)
      upload_to_s3(filename, :keep_local => false)
    end

    def get_backup_path
      now = Time.now
      directory = File.join(ENV['BACKUP_PATH'], 'ludomanager', now.strftime('%Y%m%d'))
      mkdir_p directory unless File.directory?(directory)
      directory
    end

    def upload_to_s3(filename, opts = {})
      s3 = AWS::S3.new
      bucket = s3.buckets['ludomanager']
      remote_path = Pathname.new("backups/#{Time.now.strftime('%Y%m%d')}/#{File.basename(filename)}")
      bucket.objects[remote_path].write(IO.read(filename))
      keep_local = opts.fetch(:keep_local) { true }
      if !keep_local &&  bucket.objects[remote_path].exists?
        rm filename
      end
    end



  end

end

