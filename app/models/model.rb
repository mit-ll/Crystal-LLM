class Model < ApplicationRecord
  validates :tool_id, presence: true
  validates :modelname, presence: true
end  # class
