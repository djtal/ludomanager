# # encoding: UTF-8

require 'digest/sha1'
class Account < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates :login, :email, presence: true
  validates :password, presence: {  if: :password_required? }
  validates :password_confirmation, presence: {  if: :password_required? }
  validates :password, length: { within: 4..40, if: :password_required? }
  validates :password, confirmation: { if: :password_required? }
  validates :login, length: { within: 3..40 }
  validates :email, length: { within: 3..100 }
  validates :login, :email, uniqueness: { case_sensitive: false }

  before_save :encrypt_password

  has_many :account_games, dependent: :delete_all

  has_many :parties, dependent: :delete_all do
    # return array containing 2 values
    # => total of parties played with game i own
    # => total of parties played with other game
    def split_mine(games)
      ids = games.map{|g| g.id}
      mine = count(conditions: { game_id: ids } )
      [mine , count - mine]
    end
  end

  has_many :games, through: :account_games
  has_many :played_games, through: :parties, source: :game

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  protected
    # before filter
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end

    def password_required?
      crypted_password.blank? || !password.blank?
    end


end
