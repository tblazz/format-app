class Dbfile < ApplicationRecord
  attr_accessor :col_indexs, :format, :headers, :event_name, :distance, :sport, :manif_key, :race_key
  has_one_attached :file
  has_one_attached :exported_file
end
