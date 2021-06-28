class User < ApplicationRecord
  has_many :payments
  has_one :subscription

  validates :email,
    presence: { message: I18n.t('user.validations.email.required') },
    uniqueness: {
      case_sensitive: false,
      message: I18n.t('user.validations.email.already_taken')
    },
    length: { minimum: 4, maximum: 254 },
    email: {mode: :strict}

  validates :locale,
    presence: true,
    inclusion: { in: ['fr', 'en'] }

    def user_details(id)
      User.where(id: id).first # business logic should be moved to the model
    end
end
