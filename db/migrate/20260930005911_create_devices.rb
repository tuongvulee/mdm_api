class CreateDevices < ActiveRecord::Migration[8.1]
  def change
    create_table :devices do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :platform, null: false
      t.string :serial_number, null: false
      t.string :status, null: false, default: "active"

      t.timestamps

      t.check_constraint "platform IN ('ios', 'android', 'windows')", name: "devices_platform_check"
      t.check_constraint "status IN ('active', 'inactive')", name: "devices_status_check"
    end
    add_index :devices, :serial_number, unique: true
  end
end
