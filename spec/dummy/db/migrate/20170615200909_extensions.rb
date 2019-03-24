class Extensions < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'pgcrypto'
    enable_extension 'plpgsql'
    enable_extension 'uuid-ossp'
  end
end
