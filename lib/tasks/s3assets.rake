

namespace :refinery do
  desc "download image and resource assets from s3"
  task :download_s3_assets => :environment do
    Refinery::S3assets::Util.pull
  end
end