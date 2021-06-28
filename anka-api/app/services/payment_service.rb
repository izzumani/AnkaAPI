class PaymentService

  attr_reader :data

  def initialize(params = {})
    @data = OpenStruct.new(params)
    @data.currency = 'EUR'
    @data = process_expiry(@data)
  end

  def call
    client = Rails.application.config.adyen
    result = client.checkout.payments(payment_payload(@data))

    if result.status == 200
      payment = Payment.new(
        user_id: @data.user_id,
        plan_id: @data.plan_id,
        amount: @data.amount,
        response_details: result.response.to_json
      )

      if result.response.resultCode == 'Authorised'
        payment.accepted = true
        payment.pspReference = result.response.pspReference
        payment.save

        subs = Subscription.create(user_id: @data.user_id, active: true, plan_id: payment.plan_id, payment_id: payment.id)

        return OpenStruct.new(Subscription: subs, authorised: true, redirect: false)
      end

      if result.response.resultCode == 'RedirectShopper'
        payment.accepted = false
        payment.save

        return OpenStruct.new(authorised: false, redirect: true, url: result.response.action.url)
      end
    end

    return OpenStruct.new(payment: nil, done: true)
  end

  def self.payment_details(payment_details, order_ref)
    user_id = order_ref.split('-').last
    payment = Payment.select(:id, :amount, :plan_id).where(user_id: user_id).order('id DESC').first

    user = User.where(id: user_id).select(:id, :email).first
    if payment
      client = Rails.application.config.adyen
      resp   = client.checkout.payments.details(payment_details)

      if resp.response.resultCode == 'Authorised'
        subs = Subscription.create(user_id: user_id, active: true, plan_id: payment.plan_id, payment_id: payment.id)
        obj = {
          email: user.email,
          plan_id: payment.plan_id,
          subscription_type: I18n.t("plans.#{payment.plan.title}"),
          subscription_status: subs.active,
          subscription_fees: payment.plan.fees,
          created_at: I18n.l(subs.created_at, format: :long)
        }

        return obj
      end
    end

    return {
      email: user&.email,
      plan_id: nil,
      subscription_type: '',
      subscription_status: false,
      created_at: nil
    }
  end

  private

  def payment_payload(data)
    payload = {
      "card": {
        "number": data.card_number,
        "expiryMonth": data.card_expiry_month,
        "expiryYear": data.card_expir_year,
        "cvc": data.card_cvc,
        "holderName": data.card_holder_name
      },
      "amount": {
        "value": data.amount,
        "currency": data.currency
      },
      "reference": data.user_id,
      "merchantAccount": Rails.application.config.merchant_account,
      "paymentMethod": {  type: 'scheme' },
      "shopperEmail": data.email,
      "returnUrl": "anka://?orderRef=OR-#{DateTime.now.to_i}-#{data.user_id}",
      "channel": 'web',
      :browserInfo => {
        :userAgent => "Mozilla\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\/537.36 (KHTML, like Gecko) Chrome\/70.0.3538.110 Safari\/537.36",
        :acceptHeader => "text\/html,application\/xhtml+xml,application\/xml;q=0.9,image\/webp,image\/apng,*\/*;q=0.8",
        :language=>data.locale
      }
    }

    return payload
  end

  def process_expiry(data)
    exp_date  = data.card_expiry_date
    exp_month = exp_date.split('/').first

    year       = Date.today.year.to_s
    year[2..3] = exp_date.split('/').last
    exp_year   = year

    data.card_expiry_month = exp_month
    data.card_expir_year   = exp_year

    return data
  end
end
