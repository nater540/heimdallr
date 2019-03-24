class AddHeimdallrTo<%= table_name.camelize %> < ActiveRecord::Migration<%= "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]" %>
  def up
    execute <<-SQL
      CREATE TYPE jwt_algorithms AS ENUM ('HS256', 'HS384', 'HS512', 'RS256', 'RS384', 'RS512');
    SQL

    change_table :<%= table_name %> do |t|
      t.string :key,    null: false, index: :unique
      t.string :scopes, null: false, default: '{}', array: true
      t.string :secret, null: false

      t.text :certificate, null: true

      t.column :algorithm, :jwt_algorithms, null: false, default: 'RS256'

      t.inet :ip, null: true
    end
  end

  def down
    remove_column :<%= table_name %>, :key
    remove_column :<%= table_name %>, :scopes
    remove_column :<%= table_name %>, :algorithm
    remove_column :<%= table_name %>, :secret
    remove_column :<%= table_name %>, :certificate
    remove_column :<%= table_name %>, :ip

    execute <<-SQL
      DROP TYPE jwt_algorithms;
    SQL
  end
end
