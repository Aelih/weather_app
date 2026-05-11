class WeatherController < ApplicationController
  def index
    @history = WeatherRequest.order(created_at: :desc).limit(10)
  end

  def search
    city = params[:city].to_s.strip

    if city.empty?
      @weather = { error: "Введите город" }
      render :index
      return
    end

    @weather = WeatherClient.fetch(city)

    unless @weather[:error]
      WeatherRequest.create!(
        city: @weather[:city],
        country: @weather[:country],
        temperature: @weather[:temperature],
        condition: @weather[:condition],
        wind_speed: @weather[:wind_speed]
      )
    end

    @history = WeatherRequest.order(created_at: :desc).limit(10)

    render :index
  end
end
