class Task < ApplicationRecord
  belongs_to :project

  def self.ransackable_attributes(auth_object = nil)
    %w[title created_at sort_order status]
  end
end
