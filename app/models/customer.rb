class Customer < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :rememberable, :validatable

  validates :name,
            uniqueness: true,
            presence: true,
            length: { minimum: 2, maximum: 40 }
  validates :email,
            uniqueness: true,
            presence: true
  validates :status,
            presence: true

  enum status: {
    normal: 0,
    withdrawn: 1,
    banned: 2
  }

  has_many :cart_items, dependent: :destroy
  has_many :orders, dependent: :destroy

  def line_items_checkout
    cart_items.map do |cart_item|
      {
        quantity: cart_item.quantity,
        price_data: {
          currency: 'jpy',
          unit_amount: cart_item.product.price,
          product_data: {
            name: cart_item.product.name,
            metadata: {
              product_id: cart_item.product_id
            }
          }
        }
      }
    end
  end

  def active_for_authentication?
    super && (status == 'normal')
  end
end
