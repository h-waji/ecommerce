class Admins::PagesController < ApplicationController
  before_action :authenticate_admin!

  def home
    @orders, @selected = get_orders(params)
    today_orders = Order.created_today
    @today_total_orders = total_orders(today_orders)
    @today_total_sales = total_sales(today_orders)
  end

  private

  def get_orders(params)
    return [Order.eager_load(:customer).latest, 'all'] if !params[:status].present? || !Order.statuses.keys.to_a.include?(params[:status])

    get_by_enum_value(params[:status])
  end

  def get_by_enum_value(status)
    case status
    when 'waiting_payment'
      [Order.eager_load(:customer).latest.waiting_payment, 'waiting_payment']
    when 'confirm_payment'
      [Order.eager_load(:customer).latest.confirm_payment, 'confirm_payment']
    when 'shipped'
      [Order.eager_load(:customer).latest.shipped, 'shipped']
    when 'out_of_delivery'
      [Order.eager_load(:customer).latest.out_of_delivery, 'out_of_delivery']
    when 'delivered'
      [Order.eager_load(:customer).latest.delivered, 'delivered']
    end
  end

  def total_orders(orders)
    orders.count
  end

  def total_sales(orders)
    orders.sum(:billing_amount)
  end
end
