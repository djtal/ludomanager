# # encoding: UTF-8

require 'digest/sha1'
class Account < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   if: :password_required?
  validates_presence_of     :password_confirmation,      if: :password_required?
  validates_length_of       :password, within: 4..40, if: :password_required?
  validates_confirmation_of :password,                   if: :password_required?
  validates_length_of       :login,    within: 3..40
  validates_length_of       :email,    within: 3..100
  validates_uniqueness_of   :login, :email, case_sensitive: false
  before_save :encrypt_password

  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation

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
  has_many :members, dependent: :delete_all do
    # Import member data from csv file
    # format : name(mandatory);nickname(mandatory);email(optional)
    def import(data)
      imported = 0
      errors = {}
      line = 1
      ::CSV::Reader.parse(data, ";") do |row|
        member = self.new(name: row[0], nickname: row[1], email: row[2], account: proxy_owner)
        if member.save
          imported += 1
        else
          errors[line] = member.errors
        end
        line += 1
      end
      return imported, errors
    end

  end

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
