

namespace :refinery do
  desc "download image and resource assets from s3"
  task :download_s3_assets => :environment do
    Refinery::S3assets::Util.pull
  end
  
  desc "upload image and resource assets to s3"
  task :upload_s3_assets => :environment do
    Refinery::S3assets::Util.push
  end
end