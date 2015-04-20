class AddColorToSessions < ActiveRecord::Migration
  def change
    add_column :fullcalendar_engine_sessions, :color, :string
  end
end
