class Project < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[name]
  end
end
