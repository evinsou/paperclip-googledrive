# PaperclipGoogledrive
[![Gem Version](https://badge.fury.io/rb/paperclip-googledrive.png)](http://badge.fury.io/rb/paperclip-googledrive)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/evinsou/paperclip-googledrive)

This gem currently is supporting google-api-ruby-client (~> 0.11).

PaperclipGoogledrive is a gem that extends paperclip storage for Google Drive. Works with Rails 3.x.

## Installation

Add this line to your application's Gemfile:

    gem 'paperclip-googledrive'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install paperclip-googledrive

## Google Drive Setup

Google Drive is a free service for file storage files. In order to use this storage you need a Google (or Google Apps) user which will own the files, and a Google API client.

1. Go to the [Google Developers console](https://console.developers.google.com/project) and create a new project.

2. Go to "APIs & Auth > APIs" and enable "Drive API". If you are getting an "Access Not Configured" error while uploading files, this is due to this API not being enabled.

3. Go to "APIs & Auth > Credentials" and create a new OAuth 2.0 Client ID; select "service account key" type,

4. Now you can download the credentials in JSON.

5. Create a folder in which the files will be uploaded; note the folder's ID.

6. Set an environmental variable `GOOGLE_APPLICATION_CREDENTIALS` to be the JSON credentials. And `GOOGLE_FOLDER_ID` be the folder's ID.

## Configuration

Example:
```ruby
class Product < ActiveRecord::Base
 has_attached_file :photo,
    :storage => :google_drive,
    :google_drive_options => {
      :path => proc { |style| "#{style}_#{id}_#{avatar.original_filename}" },
      :public_folder_id => ENV["GOOGLE_FOLDER_ID"],
      :default_url => "avatar_missing.png"
    }
end
```

## Options

The `:google_drive_options` option

This is a hash containing any of the following options:
 - `:path` – block, works similarly to Paperclip's `:path` option
 - `:public_folder_id`- id of folder that must be created in google drive and set public permissions on it
 - `:default_url` - an image in Public folder that used for attachments if attachment is not present

The :path option should be a block that returns a path that the uploaded file should be saved to. The block yields the attachment style and is executed in the scope of the model instance. For example:
```ruby
class Product < ActiveRecord::Base
  has_attached_file :photo,
    :storage => :google_drive,
    :google_drive_credentials => "#{Rails.root}/config/google_drive.yml",
    :styles => { :medium => "300x300" },
    :google_drive_options => {
      :path => proc { |style| "#{style}_#{id}_#{photo.original_filename}" }
    }
end
```
For example, a new product is created with the ID of 14, and a some_photo.jpg as its photo. The following files would be saved to the Google Drive:

Public/14_some_photo.jpg
Public/14_some_photo_medium.jpg

The another file is called some_photo_medium.jpg because style names (other than original) will always be appended to the filenames, for better management.

## Misc

Useful links
[Google APIs console](https://code.google.com/apis/console/)

[Google Drive scopes](https://developers.google.com/drive/scopes)

[Enable the Drive API and SDK](https://developers.google.com/drive/enable-sdk)

[Quickstart](https://developers.google.com/drive/quickstart-ruby#step_1_enable_the_drive_api)

## License

[MIT License](https://github.com/evinsou/paperclip-googledrive/blob/master/LICENSE)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
