class ApplicationController < ActionController::API
  before_action :underscore_params!

  around_action :switch_locale

  def underscore_params!
    params.deep_transform_keys!(&:underscore)
    # if it fails should not allow continue
  end

  def switch_locale(&action)
    arg = params[:locale].to_s

    if arg.length == 5
      params[:locale] = arg[0..1]
    end
    # yield function is missing should be added
    locale =  I18n.default_locale

    if ['fr', 'en'].include?(params[:locale])
      locale = params[:locale] || I18n.default_locale
    end
    I18n.with_locale(locale, &action)
  end
end
