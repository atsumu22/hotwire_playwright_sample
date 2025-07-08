class Project < ApplicationRecord
  has_many :tasks, dependent: :destroy
  validates :name, presence: true

  def self.ransackable_attributes(auth_object = nil)
    %w[name id]
  end
end
