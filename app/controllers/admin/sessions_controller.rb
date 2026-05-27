class Admin::SessionsController < ApplicationController
    def new
    end

    def create
        if params[:username] == 'admin' && params[:password] == 'password123'
        session[:admin_logged_in] = true 
        redirect_to admin_root_path, notice: 'Đăng nhập thành công!'
        else
        flash.now[:alert] = 'Tài khoản hoặc mật khẩu không chính xác!'
        render :new, status: :unprocessable_entity
        end
    end

    def destroy
        session.delete(:admin_logged_in) 
        redirect_to root_path, notice: 'Đã đăng xuất khỏi hệ thống!'
    end
end
