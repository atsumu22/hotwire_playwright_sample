class Task < ApplicationRecord
  belongs_to :project
  acts_as_list column: :sort_order, scope: :project

  def self.ransackable_attributes(auth_object = nil)
    %w[title created_at sort_order status]
  end
end
