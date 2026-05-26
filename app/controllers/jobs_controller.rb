class JobsController < ApplicationController
  def index
    @jobs = Job.all
    @jobs = @jobs.search_by_title(params[:q])
    @jobs = @jobs.filter_by_location(params[:location])
    @jobs = @jobs.newest
    @jobs = @jobs.page(params[:page]).per(20)

    @locations = Job.distinct.pluck(:location).compact.reject(&:empty?).sort
  end

  def show
    @job = Job.find(params[:id])
  end
end
