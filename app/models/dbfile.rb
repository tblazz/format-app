class Dbfile < ApplicationRecord
  attr_accessor :col_indexs, :test
  has_one_attached :file
  has_one_attached :exported_file

end
