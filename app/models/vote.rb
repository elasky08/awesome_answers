class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :question

  validates :user_id, uniqueness: { scope: :question_id }

  def self.up
    where(is_up: true)
  end

  def self.down
    where(is_up: false)
  end

end
