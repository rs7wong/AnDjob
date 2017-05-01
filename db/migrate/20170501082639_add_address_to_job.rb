class AddAddressToJob < ActiveRecord::Migration[5.0]
  def change
    # 工作地點
    add_column :jobs, :address, :string

    # 需要用到的經緯度欄位
    add_column :jobs, :latitude, :float
    add_column :jobs, :longitude, :float
  end
end
