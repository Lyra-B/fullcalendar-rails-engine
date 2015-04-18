require_dependency 'fullcalendar_engine/application_controller'

module FullcalendarEngine
  class SessionsController < ApplicationController

    layout FullcalendarEngine::Configuration['layout'] || 'application'

    before_filter :load_session, only: [:edit, :update, :destroy, :move, :resize]
    before_filter :determine_session_type, only: :create

    def create
      if @session.save
        render nothing: true
      else
        render text: @session.errors.full_messages.to_sentence, status: 422
      end
    end

    def new
      respond_to do |format|
        format.js
      end
    end

    def get_sessions
      start_time = Time.at(params[:start].to_i).to_formatted_s(:db)
      end_time   = Time.at(params[:end].to_i).to_formatted_s(:db)

      @sessions = Session.where('
                  (starttime >= :start_time and endtime <= :end_time) or
                  (starttime >= :start_time and endtime > :end_time and starttime <= :end_time) or
                  (starttime <= :start_time and endtime >= :start_time and endtime <= :end_time) or
                  (starttime <= :start_time and endtime > :end_time)',
                  start_time: start_time, end_time: end_time)
      sessions = []
      @sessions.each do |session|
        sessions << { id: session.id,
                    title: session.title,
                    description: session.description || '',
                    start: session.starttime.iso8601,
                    end: session.endtime.iso8601,
                    allDay: session.all_day,
                    recurring: (session.session_series_id) ? true : false }
      end
      render json: sessions.to_json
    end

    def move
      if @session
        @session.starttime = make_time_from_minute_and_day_delta(@session.starttime)
        @session.endtime   = make_time_from_minute_and_day_delta(@session.endtime)
        @session.all_day   = params[:all_day]
        @session.save
      end
      render nothing: true
    end

    def resize
      if @session
        @session.endtime = make_time_from_minute_and_day_delta(@session.endtime)
        @session.save
      end
      render nothing: true
    end

    def edit
      render json: { form: render_to_string(partial: 'edit_form') }
    end

    def update
      case params[:session][:commit_button]
      when 'Update All Occurrence'
        @sessions = @session.session_series.sessions
        @session.update_sessions(@sessions, session_params)
      when 'Update All Following Occurrence'
        @sessions = @session.session_series.sessions.where('starttime > :start_time',
                                                   start_time: @session.starttime.to_formatted_s(:db)).to_a
        @session.update_sessions(@sessions, session_params)
      else
        @session.attributes = session_params
        @session.save
      end
      render nothing: true
    end

    def destroy
      case params[:delete_all]
      when 'true'
        @session.session_series.destroy
      when 'future'
        @sessions = @session.session_series.sessions.where('starttime > :start_time',
                                                   start_time: @session.starttime.to_formatted_s(:db)).to_a
        @session.session_series.sessions.delete(@sessions)
      else
        @session.destroy
      end
      render nothing: true
    end

    protected

    def load_session
      @session = Session.where(:id => params[:id]).first
      unless @session
        render json: { message: "Session Not Found.."}, status: 404 and return
      end
    end

    def session_params
      params.require(:session).permit('title', 'description', 'starttime', 'endtime', 'all_day', 'period', 'frequency', 'commit_button', 'coach_id', 'administrator_id')
    end

    def determine_session_type
      if params[:session][:period] == "Does not repeat"
        @session = Session.new(session_params)
      else
        @session = SessionSeries.new(session_params)
      end
    end

    def make_time_from_minute_and_day_delta(session_time)
      params[:minute_delta].to_i.minutes.from_now((params[:day_delta].to_i).days.from_now(session_time))
    end
  end
end
