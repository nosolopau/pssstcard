class MainController < ApplicationController
  def index
    require 'encryptor'

    @text = if params[:text]
      secret_key = params[:key]
      text = params[:text]

      if encrypt?
        Base64.encode64(Encryptor.encrypt(text, key: secret_key, algorithm: 'rc4'))
      else
        Encryptor.decrypt(Base64.decode64(text), key: secret_key, algorithm: 'rc4')
      end
    else
      ''
    end
  end

  private

  def encrypt?
    params[:encrypt].present?
  end
end
