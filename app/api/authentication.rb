module Authentication
  extend ActiveSupport::Concern

  included do
    helpers do
      def authenticate!
        error!('Unauthorized. Invalid or expired token.', 401) unless current_station
      end

      def current_station
        if token = request.headers[API::TOKEN_NAME]
          @current_station ||= Station.where(token: token).first
          return @current_station
        end
        false
      end
    end
  end
end
