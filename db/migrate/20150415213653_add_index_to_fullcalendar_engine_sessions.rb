class AddIndexToFullcalendarEngineSessions < ActiveRecord::Migration
  def change
    add_index :fullcalendar_engine_sessions, :session_series_id
  end
end
