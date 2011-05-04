require 'aws/s3'
require 'heroku/command'
require 'progress_bar'

module Refinery
  module S3assets
    class MyRailtie < Rails::Railtie
      rake_tasks do
        Dir[File.join(File.dirname(__FILE__),'tasks/*.rake')].each { |f| load f }
      end
    end
    
    class Util

      def self.pull
        raise(StandardError, "no S3_KEY config var or environment variable found") if s3_config[:s3_key].nil?
        raise(StandardError, "no S3_SECRET config var or environment variable found") if s3_config[:s3_secret].nil?
        raise(StandardError, "no S3_BUCKET config var or environment variable found") if s3_config[:s3_bucket].nil?
        copy_s3_bucket(s3_config[:s3_key], s3_config[:s3_secret], s3_config[:s3_bucket], 'public/system')
      end

      private

      def self.copy_s3_bucket(s3_key, s3_secret, s3_bucket, output_path)
        AWS::S3::Base.establish_connection!(:access_key_id => s3_key, :secret_access_key => s3_secret)
        bucket = AWS::S3::Bucket.find(s3_bucket)

        puts "There are #{Image.count} images in the #{s3_bucket} bucket"        
        Image.all.each do |image|
          object = AWS::S3::S3Object.find image.image_uid,s3_bucket
          dest = File.join(output_path,"images",object.key)
          copy_s3_object(object,dest)
        end
        
        puts "\n\nThere are #{Resource.count} resources in the #{s3_bucket} bucket"        
        Resource.all.each do |resource|
          object = AWS::S3::S3Object.find resource.file_uid,s3_bucket
          dest = File.join(output_path,"resources",object.key)
          copy_s3_object(object,dest)
        end
        
      end

      def self.copy_s3_object(s3_object, to)
        FileUtils::mkdir_p File.dirname(to), :verbose => false

        filesize = s3_object.about['content-length'].to_f
        puts "Saving #{s3_object.key} (#{filesize} bytes):"

        bar = ProgressBar.new(filesize, :percentage, :counter)

        open(to, 'w') do |f|
          s3_object.value do |chunk|
            bar.increment! chunk.size
            f.puts chunk
          end
        end

        puts "\n=======================================\n"
      end
      
      def self.s3_config
        return @s3_config unless @s3_config.nil?
        
        heroku_command = Heroku::Command::Base.new({})
        
        begin
          app = heroku_command.extract_app
        rescue 
          puts "This does not look like a Heroku app!"
          exit
        end
        
        config_vars =  heroku_command.heroku.config_vars(app)
        
        @s3_config = {
          :s3_key => ENV['S3_KEY'] || config_vars['S3_KEY'],
          :s3_secret => ENV['S3_SECRET'] || config_vars['S3_SECRET'],
          :s3_bucket => ENV['S3_BUCKET'] || config_vars['S3_BUCKET']
        }
      end

    end
  end
end

