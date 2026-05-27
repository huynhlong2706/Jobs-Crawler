class Admin::JobsController < ApplicationController
    before_action :require_admin
    def index
        @jobs = Job.order(posted_at: :desc).page(params[:page]).per(20)
    end

    def edit
        @job = Job.find(params[:id])
    end

    def update
        @job = Job.find(params[:id])
        if @job.update(job_params)
        redirect_to admin_jobs_path, notice: 'Đã cập nhật thông tin việc làm!'
        else
        render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @job = Job.find(params[:id])
        @job.destroy
        redirect_to admin_jobs_path, notice: 'Đã xóa việc làm thành công!'
    end

    private

    def job_params
        params.require(:job).permit(:title, :company_name, :salary, :location, :description)
    end

    def require_admin
        unless session[:admin_logged_in]
            redirect_to admin_login_path, alert: 'Vui lòng đăng nhập để truy cập trang quản trị!'
        end
    end
end
