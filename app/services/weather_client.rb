require "net/http"
require "json"
require "uri"

class WeatherClient
  def self.fetch(city)
    location = find_location(city)

    return { error: "Город не найден" } if location.nil?

    weather = fetch_weather(location[:latitude], location[:longitude])

    {
      city: location[:name],
      country: location[:country],
      temperature: weather["current"]["temperature_2m"],
      wind_speed: weather["current"]["wind_speed_10m"],
      condition: weather_description(weather["current"]["weather_code"]),
      fetched_at: Time.current
    }
  rescue StandardError => e
    {
      error: "Ошибка получения погоды: #{e.message}"
    }
  end

  def self.find_location(city)
    url = URI("https://geocoding-api.open-meteo.com/v1/search?name=#{URI.encode_www_form_component(city)}&count=1&language=ru&format=json")

    response = Net::HTTP.get(url)
    data = JSON.parse(response)

    result = data["results"]&.first
    return nil unless result

    {
      name: result["name"],
      country: result["country"],
      latitude: result["latitude"],
      longitude: result["longitude"]
    }
  end

  def self.fetch_weather(latitude, longitude)
    url = URI("https://api.open-meteo.com/v1/forecast?latitude=#{latitude}&longitude=#{longitude}&current=temperature_2m,wind_speed_10m,weather_code")

    response = Net::HTTP.get(url)
    JSON.parse(response)
  end

  def self.weather_description(code)
    descriptions = {
      0 => "Ясно",
      1 => "Преимущественно ясно",
      2 => "Переменная облачность",
      3 => "Пасмурно",
      45 => "Туман",
      48 => "Инейный туман",
      51 => "Слабая морось",
      53 => "Умеренная морось",
      55 => "Сильная морось",
      61 => "Слабый дождь",
      63 => "Умеренный дождь",
      65 => "Сильный дождь",
      71 => "Слабый снег",
      73 => "Умеренный снег",
      75 => "Сильный снег",
      80 => "Слабый ливень",
      81 => "Умеренный ливень",
      82 => "Сильный ливень",
      95 => "Гроза"
    }

    descriptions[code] || "Неизвестно"
  end
end
