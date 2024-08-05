class PostsController < ApplicationController
  before_action :check_logon, except: %w[show]
  before_action :set_forum, only: %w[create new]
  before_action :set_post, only: %w[show edit update destroy]
  before_action :check_access, only: %w[edit update destroy]
  
  def create
    @post = @forum.posts.new(post_params)
    if @post.save
      redirect_to @post, notice: "Your post was created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def new
    @post = @forum.posts.new
  end

  def edit
  end

  def show
  end

  def update
    if @post.update(post_params)
      redirect_to @post, notice: "Your post was updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @forum = @post.forum
    @post.destroy
    redirect_to @forum, notice: "Your post was deleted."
  end

  private

    def check_logon
      if !@current_user
        redirect_to forums_path, notice: "You can't add, modify, or delete posts before logon."
      end
    end

    def set_forum
      @forum = Forum.find(params[:forum_id])
    end

    def set_post
      @post = Post.find(params[:id])
    end

    def check_access
      if @post.user_id != session[:current_user]
        redirect_to forums_path, notice: "That's not your post, so you can't change it."
      end
    end

   

    def post_params
      Rails.logger.debug "Params: #{params.inspect}"
      Rails.logger.debug "Session: #{session.inspect}"
      # Log current_user before setting user_id
      Rails.logger.debug "Session current_user: #{session[:current_user].inspect}"

      # Log params[:post] before attempting to set user_id
      Rails.logger.debug "params[:post] before setting user_id: #{params[:post].inspect}"

      # Attempt to set the user_id in the post parameters
      params[:post][:user_id] = @current_user.id

      # Log params[:post] after attempting to set user_id
      Rails.logger.debug "params[:post] after setting user_id: #{params[:post].inspect}"

      # Permit only the allowed parameters
      permitted_params = params.require(:post).permit(:title, :content, :user_id)
      Rails.logger.debug "Permitted params: #{permitted_params.inspect}"

      permitted_params
    end
end
