class ApplicationController < ActionController::Base
    # Previne ataques CSRF exigindo um token válido
    protect_from_forgery with: :exception
    
    # Método para lidar com erros de CSRF
    def handle_unverified_request
      flash[:error] = "Erro de segurança. Por favor, tente novamente."
      redirect_to root_path
    end
  end