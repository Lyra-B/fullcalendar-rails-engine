class RenameFullcalendarEngineEventSeriesToFullcalendarEngineSessionSeries < ActiveRecord::Migration
  def change
    rename_table :fullcalendar_engine_event_series, :fullcalendar_engine_session_series
  end
end
