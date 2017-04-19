require 'active_support/core_ext/hash/keys'
require 'active_support/inflector/methods'
require 'active_support/core_ext/object/blank'
require 'yaml'
require 'erb'
require 'googleauth'
require 'google/apis/drive_v3'
require 'net/http'

module Paperclip

  module Storage
      # * self.extended(base) add instance variable to attachment on call
      # * url return url to show on site with style options
      # * path(style) return title that used to insert file to store or find it in store
      # * public_url_for title  return url to file if find by title or url to default image if set
      # * search_for_file(name) take name, search in given folder and if it finds a file, return id of a file or nil
      # * metadata_by_id(file_i get file metadata from store, used to back url or find out value of trashed
      # * exists?(style)  check either exists file with title or not
      # * default_image  return url to default url if set in option
      # * find_public_folder return id of Public folder, must be in options
      # return id of Public folder, must be in options
      # * file_tit return base pattern of title or custom one set by user
      # * parse_credentials(credenti get credentials from file, hash or path
      # * assert_required_keys  check either all ccredentials keys is set
      # * original_extension  return extension of file

    module GoogleDrive
      SCOPE = "https://www.googleapis.com/auth/drive"

      def self.extended(base)
        begin
          require 'google-api-client'
        rescue LoadError => e
          e.message << " (You may need to install the google-api-client gem)"
          raise e
        end unless defined?(Google)

        base.instance_eval do
          @google_drive_options = @options[:google_drive_options] || {}
          @google_drive_client
        end
      end
      #
      def flush_writes
        @queued_for_write.each do |style, file|
          if exists?(path(style))
            raise FileExists, "file \"#{path(style)}\" already exists in your Google Drive"
          else
            title, mime_type = title_for_file(style), "#{content_type}"
            parent_id = find_public_folder
            file_metadata = { name: title, parents: [parent_id] }
            metadata = google_api_client.create_file(file_metadata,
              upload_source: file.path,
              content_type: content_type)
          end
        end
        after_flush_writes
        @queued_for_write = {}
      end
      #
      def flush_deletes
        @queued_for_delete.each do |path|
          Paperclip.log("delete #{path}")
          the_item = search_for_file(path)
          google_api_client.delete_file(the_item[:id]) if the_item
        end
        @queued_for_delete = []
      end

      def copy_to_local_file(style, local_dest_path)
        the_item = search_for_file(path(style))
        google_api_client.get_file(the_item[:id], download_dest: local_dest_path)
        true
      end
      #
      def google_api_client
        @google_api_client ||= begin
          drive = Google::Apis::DriveV3::DriveService.new
          drive.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
            scope: SCOPE,
            json_key_io: StringIO.new(google_app_credentials)
          )
          drive
        end
      end

      def url(*args)
        if present?
          style = args.first.is_a?(Symbol) ? args.first : default_style
          options = args.last.is_a?(Hash) ? args.last : {}
          public_url_for(path(style))
        else
          default_image
        end
      end

      def path(style)
        title_for_file(style)
      end

      def title_for_file(style)
        file_name = instance.instance_exec(style, &file_title)
        style_suffix = (style != default_style ? "_#{style}" : "")
        if original_extension.present? && file_name =~ /#{original_extension}$/
          file_name.sub(original_extension, "#{style_suffix}#{original_extension}")
        else
          file_name + style_suffix + original_extension.to_s
        end
      end # full title

      def public_url_for title
        the_item = search_for_file(title)
        the_item ? the_item[:link] : default_image
      end # url
      # take name, search in given folder and if it finds a file, return id of a file or nil
      def search_for_file(name)
        result = google_api_client.list_files(
          q: "name contains '#{name}' and '#{find_public_folder}' in parents",
          corpora: 'user', fields: 'files(id, name, trashed, webContentLink)'
        )

        if result.files.length > 0
          file = result.files.first
          {
            link: file.web_content_link.sub('download', 'view'),
            id: file.id,
            trashed: file.trashed
          }
        elsif result.files.length == 0
          nil
        else
          nil
        end
      end # id or nil

      def exists?(style = default_style)
        return false if not present?
        result = search_for_file(path(style))
        if result.nil?
          false
        else
          !result[:trashed]
        end
      end

      def default_image
        @google_drive_options[:default_url] || "missing.png"
      end

      def find_public_folder
        unless @google_drive_options[:public_folder_id]
          raise KeyError, "you must set a Public folder if into options"
        end
        @google_drive_options[:public_folder_id]
      end
      class FileExists < ArgumentError
      end

      private

      def google_app_credentials
        @google_app_credentials ||= ENV["GOOGLE_APPLICATION_CREDENTIALS"]
      end

      def file_title
        return @google_drive_options[:path] if @google_drive_options[:path] #path: proc
        eval %(proc { |style| "\#{id}_\#{#{name}.original_filename}"})
      end

      # return extension of file
      def original_extension
        File.extname(original_filename)
      end
    end
  end
end
