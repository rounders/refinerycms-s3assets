require 'aws/s3'
require 'heroku/command/base'
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
        raise(StandardError, "no S3_KEY config var or environment variable found") if s3_config[:key].nil?
        raise(StandardError, "no S3_SECRET config var or environment variable found") if s3_config[:secret].nil?
        raise(StandardError, "no S3_BUCKET config var or environment variable found") if s3_config[:bucket].nil?
        copy_s3_bucket(s3_config[:key], s3_config[:secret], s3_config[:bucket], 'public/system/refinery')
      end

    private

      def self.copy_s3_bucket(s3_key, s3_secret, s3_bucket, output_path)
        AWS::S3::Base.establish_connection!(:access_key_id => s3_key, :secret_access_key => s3_secret)
        bucket = AWS::S3::Bucket.find(s3_bucket)

        puts "There are #{Image.count} images in the #{s3_bucket} bucket"
        Image.all.each do |image|
          s3_object = AWS::S3::S3Object.find image.image_uid,s3_bucket
          dest = File.join(output_path,"images",s3_object.key)
          copy_s3_object(s3_object,dest)
        end

        puts "\n\nThere are #{Resource.count} resources in the #{s3_bucket} bucket"
        Resource.all.each do |resource|
          s3_object = AWS::S3::S3Object.find resource.file_uid,s3_bucket
          dest = File.join(output_path,"resources",s3_object.key)
          copy_s3_object(s3_object,dest)
        end

      end

      def self.copy_s3_object(s3_object, to)
        FileUtils::mkdir_p File.dirname(to), :verbose => false

        filesize = s3_object.about['content-length'].to_f
        puts "Saving #{s3_object.key} (#{filesize} bytes):"

        bar = ProgressBar.new(filesize, :percentage, :counter)

        open(to, 'wb') do |f|
          s3_object.value do |chunk|
            bar.increment! chunk.size
            f.write chunk
          end
        end

        puts "\n=======================================\n"
      end

      def self.s3_config
        return @s3_config unless @s3_config.nil?
        is_heroku_app = false

        begin
          base = Heroku::Command::BaseWithApp.new
          app = base.app
          is_heroku_app = true
        rescue
        end

        config_vars = is_heroku_app ? base.heroku.config_vars(app) : {}

        @s3_config = {
          :key => ENV['S3_KEY'] || config_vars['S3_KEY'],
          :secret => ENV['S3_SECRET'] || config_vars['S3_SECRET'],
          :bucket => ENV['S3_BUCKET'] || config_vars['S3_BUCKET']
        }

        unless [:key, :secret, :bucket].all?{|s3| @s3_config[s3].present?}
          puts "Could not get complete s3 configuration."
          puts "This application is not a Heroku application." unless is_heroku_app
          exit 1
        end

        @s3_config
      end

    end
  end
end

