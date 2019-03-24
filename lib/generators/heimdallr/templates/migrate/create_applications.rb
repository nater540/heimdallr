class HeimdallrCreate<%= table_name.camelize %> < ActiveRecord::Migration<%= "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]" %>
  def up
    execute <<-SQL
      CREATE TYPE jwt_algorithms AS ENUM ('HS256', 'HS384', 'HS512', 'RS256', 'RS384', 'RS512');
    SQL

    create_table :<%= table_name %>, id: :uuid do |t|
      t.string :name,   null: false
      t.string :key,    null: false, index: :unique
      t.string :scopes, null: false, default: '{}', array: true
      t.string :secret, null: false

      t.text :certificate, null: true

      t.column :algorithm, :jwt_algorithms, null: false, default: 'RS256'

      t.inet :ip, null: true
    end
  end

  def down
    drop_table :<%= table_name %>

    execute <<-SQL
      DROP TYPE jwt_algorithms;
    SQL
  end
end
