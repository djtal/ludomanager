class Member < ActiveRecord::Base
  validates :first_name, :last_name, :email, presence: true
  belongs_to :account, inverse_of: :members

  scope :active, -> { where(active: true)}


  def full_name
    "#{first_name} #{last_name}"
  end
end
