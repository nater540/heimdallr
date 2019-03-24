class AddHeimdallrTo<%= table_name.camelize %> < ActiveRecord::Migration<%= "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]" %>
  def change
    change_table :<%= table_name %> do |t|
      t.belongs_to :application, type: :uuid, index: true
      t.string :scopes, null: false, default: '{}', array: true
      t.column :data, :jsonb, null: false, default: {}

      t.inet :ip, null: true
      t.datetime :created_at, null: false
      t.datetime :expires_at, null: false
      t.datetime :revoked_at, null: true
      t.datetime :not_before, null: true
    end
  end
end
