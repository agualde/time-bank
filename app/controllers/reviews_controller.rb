class ReviewsController < ApplicationController
  def new
    @review = Review.new
    @user = User.find(params[:id])

    if user_signed_in?

      @my_projects_together = current_user.bookings.where(user_id: params[:id])
      @my_projects_together_2 = current_user.projects
      @her_projects_together = @user.projects

      @our_projects = []

      @my_projects_together.each do |booking|
        @our_projects << booking.project.title
      end

      @her_projects_together.each do |project|
        (@our_projects << project.title) if !(project.bookings.where(user_id: current_user.id, status: "Approved").empty?)
      end

      @my_projects_together_2.each do |project|
        @our_projects << project.title if project.bookings.where(user_id: @user.id, status: "Approved")
      end

    end
  end

  def create
    @review = Review.new(review_params_no_userid)
    @review.rating = params[:review][:rating].to_i
    @review.user_id = current_user.id
    if @review.save
      UserReview.create(user_id: params[:id].to_i, review_id: @review.id)
      redirect_to user_show_path(params[:id].to_i)
    else
      new
      render :new
    end
  end

  def edit
    @review = Review.find(params[:review_id])
    @user_reviewd = User.find(UserReview.where(review_id: params[:review_id])[0].user_id)

    @my_projects_together = current_user.bookings.where(user_id: @user_reviewd.id)
    @my_projects_together_2 = current_user.projects
    @her_projects_together = @user_reviewd.projects

    @our_projects = []

    @my_projects_together.each do |booking|
      @our_projects << booking.project.title
    end

    @her_projects_together.each do |project|
      (@our_projects << project.title) if !(project.bookings.where(user_id: current_user.id, status: "Approved").empty?)
    end

    @my_projects_together_2.each do |project|
      @our_projects << project.title if project.bookings.where(user_id: @user_reviewd.id, status: "Approved")
    end

  end

  def update
    @review = Review.find(params[:review_id])
    @user = UserReview.where(review_id: @review.id)[0]

    if @review.update(review_params_no_userid)
      redirect_to user_show_path(@user.user_id)
    else
      edit
      render :edit
    end
  end


  def destroy
    @review = Review.find(params[:id])
    @user = UserReview.where(review_id: @review.id)[0]

    @review.destroy
    redirect_to user_show_path(@user.user_id)

  end

  private

  def review_params_no_userid
    params.require(:review).permit(:title, :content, :project, :rating)
  end


end
