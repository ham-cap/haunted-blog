# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_blog, only: %i[edit update destroy]

  before_action :ensure_correct_user, only: %i[edit update destroy]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show
    blogs = Blog.where('secret = ? OR user_id = ?', false, current_user&.id)

    @blog = blogs.find(params[:id])
  end

  def new
    @blog = Blog.new
  end

  def edit; end

  def create
    @blog = current_user.blogs.new(blog_params)

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @blog.update(blog_params)
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog.destroy!

    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def set_blog
    @blog = Blog.find(params[:id])
  end

  def blog_params
    random_eyecatch = :random_eyecatch if current_user.premium
    params.require(:blog).permit(:title, :content, :secret, random_eyecatch)
  end

  def ensure_correct_user
    user = @blog.user
    current_user.blogs.find_by!(user_id: user.id)
  end
end
