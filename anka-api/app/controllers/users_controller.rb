class UsersController < ApplicationController


  def show
    # user = User.where(id: params[:id]).first # business logic should be moved to the model
    user = User.new.user_details(params[:id]);
    logger.debug("*********** #{user.inspect} ************");
    unless user
      render json: { message: 404 }, status: 404 and return # should use render and return to avoid double rednering
    end
    
    subs = user.subscription
    payment = subs.payment

    render json: {
      email: user.email,
      plan_id: subs.plan_id,
      subscription_type: I18n.t("plans.#{payment.plan.title}"),
      subscription_status: subs.active,
      subscription_fees: payment.plan.fees,
      created_at: I18n.l(subs.created_at, format: :long)
    }
  end

  def plans
    data = Plan.select(:id, :title, :description, :fees).all # pluck this is a business logic should move to model

    logger.debug("*********** #{data.inspect} ************");

    localized_data = data.map do |plan| # probably instead use reduce to create an array of objects
      {
        id: plan.id,
        title: I18n.t("plans.#{plan.title}"),
        description: I18n.t("plans.#{plan.description}"),
        fees: plan.fees
      }
    end

    render json: localized_data
  end

  def create
    # TO-DO : remove theses statements
    Subscription.delete_all  # move this functionality on model class
    Payment.delete_all # move this functional lity on model class
    User.delete_all # move this functionality on model class

    plan = Plan.where(id: params[:subscription_plan_id]).first

    unless plan
      render json: { message: 'subscription plan not found!' }, status: 404
      return
    end

    params[:amount] = plan.amount_in_cents

    user = User.new(email: params[:email].to_s, locale: params[:locale].to_s)
    user_locale = "#{user.locale}-#{user.locale.to_s.upcase}"

    if user.save
      res = PaymentService.new(params.merge(user_id: user.id, email: user.email, locale: user_locale, plan_id: plan.id)).call()

      render json: {
        user: user.attributes,
        payment: res
      }
    else
      render json: { errors: user.errors.full_messages }, status: 400
    end
  end

  def check_payment
    res = PaymentService.payment_details({ 'details': { 'redirectResult': params[:redirect_result] }}, params[:order_ref])
    render json: res
  end
end
