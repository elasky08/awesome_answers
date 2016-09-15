class Question < ApplicationRecord

  # this associates the question with answer in a one-to-many fashion this will give us handy methods to easily created associated answers and fetch associated answers as well. Note that it should be pluaralized for one to many association. You should also add a dependent option. The value can be:
  # destroy: will delete associated answers before deleting a question
  # nullify: will make question_id 'null' for associated answers before deleting
  # :answers refers to the model answer.rb
  attr_accessor :tweet_it
  has_many :answers, dependent: :destroy

  belongs_to :user

  has_many :likes, dependent: :destroy
  has_many :users, through: :likes
  has_many :votes, dependent: :destroy
  has_many :voting_users, through: :votes, source: :user
  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings

  # validates :title, uniqueness: {scope: [:body]}
  validates :title, presence: true, uniqueness: {message: "must be unique!"}
  validates :body, presence: true, length: {minimum: 5}

  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]

  # :image refers to the field in the databse that stores the file name
  #  ImageUploader refers to the Uploader class we generated with carrierwave
  mount_uploader :image, ImageUploader

  #validates (:title, {presence: true}) => more verbose way of writing
  validates :title, presence: true, uniqueness: true
  # validates :title, presence: true, uniqueness: {message: "must be unique!"}
  # validates :body, presence: true, uniqueness: {messageL "must not be blank!"}
  # validates :body, presence: true, length: {minimum: 5} => saying that characters must be at least 5

  # This validates the title/body combination is unique which means that title doesn't have to
  # be unique by itself, body doesn't have to be unique by itself but the combination
  # of the two must be unique.
  # validates :body, uniqueness: {scope: :title}

  # this code is to validate if the entered data is an email or not
  # VALID_EMAIL_REGEX = /\A([\w+\-]\.?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  # validates :email, format: VALID_EMAIL_REGEX

  # this defines a custom validation. It takes a first argument whch in this
  # case is a private method
  # validate is singular for this custom validation
  validate :no_monkey

  after_initialize :set_defaults

  before_validation :capitalize_title

  def like_for(user)
    likes.find_by_user_id(user)
  end


  def titleize_title
    title.titleize
  end

  # def to_param
  #   "#{id}-#{title}".parameterize
  # end

  # scope :recent_ten, lambda { order(created_at: :desc).limit(10)} it is the same thing as below code, this is just short-form
  def self.recent_ten
    order(created_at: :desc).limit(10)
  end

  def self.search(keyword)
    where(["title ILIKE ? OR body ILIKe ?", "%#{keyword}%", "%#{keyword}%"])
  end

  def vote_for(user)
    votes.find_by_user_id user
  end

  def vote_value
    votes.where(is_up: true).count - votes.where(is_up: false).count
  end

  delegate :first_name, :last_name, to: :user, prefix: true, allow_nil: true

  def user_first_name
    user.first_name if user
  end

  def user_last_name
    user.last_name if user
  end

  private


  def capitalize_title
    self.title.capitalize! if title
  end

  def no_monkey
    if title && title.downcase.include?("monkey")
      errors.add(:title, "No moneky please!")
    end
  end

  # calling itself when calling view_count on the console?
  def set_defaults
    self.view_count ||= 0
  end

end
