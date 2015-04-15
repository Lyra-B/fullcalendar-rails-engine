class RenameFullcalendarEngineEventsToFullcalendarEngineSessions < ActiveRecord::Migration
  def change
     rename_table :fullcalendar_engine_events, :fullcalendar_engine_sessions
  end
end
