class Dbfile < ApplicationRecord
  has_one_attached :file
  has_one_attached :exported_file

end
