class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise  :database_authenticatable, :registerable,
          :recoverable, :rememberable, :validatable

  has_many :projects, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :favorites, dependent: :destroy

  has_many :reviews, dependent: :destroy
  
  has_many :user_reviews, dependent: :destroy
  has_many :created_reviews, through: :user_reviews, source: :review, dependent: :destroy
  

  has_many :favorite_projects, through: :favorites, source: :project
  has_many :booked_projects, through: :bookings, source: :project

  has_many :user_skills, dependent: :destroy
  has_many :skills, through: :user_skills


  has_one_attached :photo
  validates :photo, size: { between: 1.kilobyte..5.megabytes , message: 'size is too big (max 5MB)' }, content_type: ['image/png', 'image/jpeg']

  has_many :messages, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :chatrooms_as_sender, class_name: "Chatroom", foreign_key: :sender_id, dependent: :destroy
  has_many :chatrooms_as_receiver, class_name: "Chatroom", foreign_key: :reciever_id, dependent: :destroy

  # validates :photo, attached: true, size: { less_than: 20.megabytes , message: 'file is too large' }

  validates :username, presence: true
  validates :email, uniqueness: true

end
