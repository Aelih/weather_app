class Api::V1::WeatherController < ApplicationController
  def show
    city = params[:city].to_s.strip

    if city.empty?
      render json: { error: "Введите город" }, status: :bad_request
      return
    end

    weather = WeatherClient.fetch(city)

    if weather[:error]
      render json: weather, status: :not_found
    else
      render json: weather
    end
  end
end
