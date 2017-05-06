class JobsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :update, :edit, :destroy, :collect, :discollect]
  before_action :validate_search_key, only: [:search]

  def show
    @job = Job.find(params[:id])

    if @job.is_hidden
      flash[:warning] = "This Job already archived."
      redirect_to root_path
    end

    # 使用經緯度兩個欄位的數值，建立 Google Map
    @hash = Gmaps4rails.build_markers(@job) do |job, marker|
      marker.lat job.latitude
      marker.lng job.longitude
    end

  end

  def index

    @jobs = case params[:order]

# 公司＋分類
    when 'by_company'
      Job.published.company.paginate(:page => params[:page], :per_page => 10)
    when 'by_category'
      Job.published.category.paginate(:page => params[:page], :per_page => 10)
# 公司＋分類

    when 'by_lower_bound'
      Job.published.order('wage_lower_bound DESC').paginate(:page => params[:page], :per_page => 10)
    when 'by_upper_bound'
      Job.published.order('wage_upper_bound DESC').paginate(:page => params[:page], :per_page => 10)
    else
      Job.published.recent.paginate(:page => params[:page], :per_page => 10)
    end

 # 判断是否筛选职位类型 #
    if params[:category].present?
      @category = params[:category]
      if @category == '所有類型'
        @jobs = Job.published.recent.paginate(:page => params[:page], :per_page => 10)
      else
        @jobs = Job.where(:is_hidden => false, :category => @category).recent.paginate(:page => params[:page], :per_page => 10)
      end
    end
# 判断是否筛选职位类型 #

  end

  def new
    @job = Job.new
  end

  def create
    @job = Job.new(job_params)

    if @job.save
      redirect_to jobs_path
    else
      render :new
    end
  end

  def edit
    @job = Job.find(params[:id])
  end

  def update
    @job = Job.find(params[:id])
    if @job.update(job_params)
      redirect_to job_path
    else
      render :edit
    end
  end

  def destroy
    @job = Job.find(params[:id])

    @job.destroy
    redirect_to jobs_path
  end

  # <!--=搜索功能=-->
  def search
    if @query_string.present?
      search_result = Job.published.ransack(@search_criteria).result(:distinct => true)
      @jobs = search_result.recent.paginate(:page => params[:page], :per_page => 10)
    end
  end
  # <!--=搜索功能=-->

  # --蒐藏工作--
  def collect
    @job = Job.find(params[:id])
    if !current_user.favorite?(@job)
     current_user.collect!(@job)
     flash[:notice] = "已成功收藏此工作"
    else
     flash[:warning] = "已經收藏過此工作"
    end
    redirect_to :back
  end

  def discollect
    @job = Job.find(params[:id])
    if current_user.favorite?(@job)
     current_user.discollect!(@job)
     flash[:alert] = "已取消收藏此工作"
    else
     flash[:alert] = "尚未收藏此工作哦！"
    end
    redirect_to :back
  end
  # --蒐藏工作--


  private

  def job_params
    params.require(:job).permit(:title, :description, :wage_upper_bound, :wage_lower_bound, :contact_email, :is_hidden, :category, :company, :city, :address, :latitude, :longitude)
  end

  # <!--=搜索功能=-->
  protected
  def validate_search_key
    @query_string = params[:q].gsub(/\\|\'|\/|\?/, "")
    if params[:q].present?
      @search_criteria =  {
        title_or_company_or_city_cont: @query_string
      }
    end
  end

  def search_criteria(query_string)
    { :title_or_name_or_category_or_company_or_city_or_address_cont => query_string }
  end
  # <!--=搜索功能=-->



end
