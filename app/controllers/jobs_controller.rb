class JobsController < ApplicationController
  def index
    @locations = Job.distinct.pluck(:location).compact.reject(&:empty?).sort

    query = params[:q].presence || "*"
    
    conditions = {}
    conditions[:location] = params[:location] if params[:location].present?

    @jobs = Job.search(
      query,
      where: conditions,
      order: { posted_at: :desc },
      page: params[:page],
      per_page: 20
    )
  end

  def show
    @job = Job.find(params[:id])
  end
end
