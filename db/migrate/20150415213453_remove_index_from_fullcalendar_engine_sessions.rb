class RemoveIndexFromFullcalendarEngineSessions < ActiveRecord::Migration
  def change
    remove_index :fullcalendar_engine_sessions, :column => :event_series_id
  end
end
