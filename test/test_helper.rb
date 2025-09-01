require "disposable"
require "minitest/autorun"
# require "representable/debug"
# require "pp"
require "declarative/testing"

# Helper method to normalize hash inspect format for cross-Ruby version compatibility
# Ruby 3.4 changed from {:key => value} to {key: value} in inspect output
def normalize_inspect(inspect_string)
  inspect_string
    .gsub(/" => /, '"=>')                      # Remove spaces around => for string keys: "key" => value → "key"=>value
    .gsub(/([{,\[]\s*)(\w+): /, '\1:\2=>')     # Convert symbol keys: {key: value} → {:key=>value} (only after {, [, or ,)
end

require "disposable/twin/coercion"
DRY_TYPES_CONSTANT = Disposable::Twin::Coercion::DRY_TYPES_CONSTANT
DRY_TYPES_INT_CONSTANT = Disposable::Twin::Coercion::DRY_TYPES_VERSION < Gem::Version.new("0.13.0") ? 'Int' : 'Integer'

class Track
  def initialize(options={})
    @title = options[:title]
  end

  attr_reader :title
end

# require 'active_record'
# require 'database_cleaner'
# DatabaseCleaner.strategy = :truncation

require 'active_record'
class Artist < ActiveRecord::Base
  has_many :albums
end

class Song < ActiveRecord::Base
  belongs_to :artist
end

class Album < ActiveRecord::Base
  has_many :songs
  belongs_to :artist
end

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => ":memory:"
)

ActiveRecord::Schema.define do
  create_table :artists do |table|
    table.column :name, :string
    table.timestamps null: false
  end
  create_table :songs do |table|
    table.column :title, :string
    table.column :artist_id, :integer
    table.column :album_id, :integer
    table.timestamps null: false
  end
  create_table :albums do |table|
    table.column :name, :string
    table.column :artist_id, :integer
    table.timestamps null: false
  end
end

module Disposable
  module Comparable
    def attributes(source)
      source.instance_variable_get(:@fields)
    end

    def ==(other)
      self.class == other.class and attributes(self) == attributes(other)
    end
  end

  module Saveable
    def save
      @saved = true
    end

    def saved?
      defined?(@saved) ? @saved : nil
    end
  end
end

