# Primary Author: Jonathan Allen (jallen01)

class Item < ActiveRecord::Base
  # Kind of a hack. Want to use currency print method in to_s method.
  include ActionView::Helpers::NumberHelper

  # Attributes
  # ----------

  has_many :partitions, dependent: :destroy
  has_many :users, through: :partitions
  belongs_to :group

  scope :ordered, -> { order :name }


  # Validations
  # -----------

  NAME_MAX_LENGTH = 20
  validates :name, presence: true, length: { minimum: 1, maximum: Item::NAME_MAX_LENGTH }
  validates :cost, presence: true, currency: true

  # Capitalize first letter of each word in name
  before_validation { self.name = self.name.downcase.split.map(&:capitalize).join(' ') }


  # Methods
  # -------

  # Returns a string representation of the item. 
  def to_s
    "#{self.name}: #{number_to_currency(self.cost, :unit => "$")}"
  end

  # Returns true if item is shared with specified user.
  def include_user?(user)
    self.users.exists?(user)
  end

  # Returns the number of users whom this item is shared with
  def count_users
    self.users.count
  end

  # Returns the partial cost of this item for users sharing it. Returns 0 if no users are sharing the item.
  def user_cost
    if self.count_users == 0
      return 0
    else
      return self.cost * (1.0 / self.count_users)
    end
  end

  # Shares item with specified user. Does nothing if item is already shared with user. Returns true if successful, false otherwise.
  def add_user(user)
    # Check that the user is in the item's group.
    if self.group.include_user?(user)
      return self.partitions.find_or_create_by(user: user)
    else  
      record.errors[:users] << (options[:message] || "is not a member of the item's group")
      return false
    end
  end

  def get_partition(user)
    return self.partitions.find_by(user: user)
  end

  # Unshares item with specified user. Does nothing if item is not already shared with user.
  def remove_user(user)
    self.partitions.destroy_all(user: user)
  end
end
