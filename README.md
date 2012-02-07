# refinerycms-s3assets

A common development scenario,  when using a Heroku-hosted Refinery CMS app, is to copy production data to development via the use of heroku db:pull. 
This gem adds a rake task to your RefineryCMS project which copies your production assets stored on s3 onto the local filesystem.

## Requirements

1. Mac OS X, Linux, or UNIX.
2. A Heroku account (or S3 credentials).
3. A Refinery CMS project

## Installation

Open up your Gemfile and add at the bottom this line:

```ruby
gem 'refinerycms-s3assets'
```

Now, run:

```shell
bundle install
```

## Usage

This gem assumes that your production Heroku app is storing assets on Amazon s3 
and that your Heroku app has the following three config vars properly defined: 
`S3_BUCKET`, `S3_KEY` and `S3_SECRET` ( see http://devcenter.heroku.com/articles/config-vars for more info). 

Start by copying your production database to your local database:

```shell
bundle exec heroku db:pull 
```

To copy all Image and Resource files from S3 you can now run the following:

```shell
bundle exec rake refinery:download_s3_assets
```

If you do not have a Heroku application but you do know the S3 credentials then you
can provide these manually as ENV variables:

```shell
S3_KEY=key S3_SECRET=secret S3_BUCKET=bucket bundle exec rake refinery:download_s3_assets
```

## License

Please see MIT-LICENSE for more details.

## Copyright

Copyright (c) 2011 Rounders Consulting Inc.
