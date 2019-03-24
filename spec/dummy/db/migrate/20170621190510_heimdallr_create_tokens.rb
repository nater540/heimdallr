class HeimdallrCreateTokens < ActiveRecord::Migration[5.1]
  def change
    create_table :tokens, id: :uuid do |t|
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
