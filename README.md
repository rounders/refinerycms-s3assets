# refinerycms-s3assets

A common development scenario,  when using a Heroku-hosted Refinery CMS app, is to copy production data to development via the use of `heroku db:pull`.
This gem adds a rake task to your Refinery CMS project which copies your production assets stored on s3 onto the local filesystem.

## Requirements

1. Mac OS X, Linux, or UNIX.
2. A Heroku account (or S3 credentials).
3. A Refinery CMS 2.x project (RefineryCMS 1.x not currently supported)

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

### Copying production data to development

Start by copying your production database to your local database:

```shell
heroku db:pull
```

To copy all Image and Resource files from S3 you can now run the following:

```shell
bundle exec rake refinery_s3_assets:pull
```

### Copying development data to production

Start by copying your development database to your production:

```shell
heroku db:push
```

To copy all Image and Resources files from local development to S3 you can run the following:

```shell
bundle exec rake refinery_s3_assets:push
```

If you do not have a Heroku application but you do know the S3 credentials then you
can provide these manually as ENV variables:

```shell
S3_KEY=key S3_SECRET=secret S3_BUCKET=bucket bundle exec rake refinery:download_s3_assets
```

## Warning

There is currently no prompting if you are overwriting existing files so please be careful.

## License

Please see MIT-LICENSE for more details.

## Copyright

Copyright (c) 2011 Rounders Consulting Inc.
