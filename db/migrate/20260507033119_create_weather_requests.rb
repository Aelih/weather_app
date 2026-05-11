class CreateWeatherRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :weather_requests do |t|
      t.string :city
      t.string :country
      t.float :temperature
      t.string :condition
      t.float :wind_speed

      t.timestamps
    end
  end
end
