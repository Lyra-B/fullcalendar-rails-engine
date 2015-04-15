class RemoveEventSeriesIdFromFullcalendarEngineSessions < ActiveRecord::Migration
  def change
    remove_column :fullcalendar_engine_sessions, :event_series_id
  end
end
