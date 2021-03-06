class ProjectsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    if params[:query].present?

      #we pass queries in the homepage; this condition is specific for everytime we pass a query

      @projects = Project.global_search(params[:query])
      @user_favorites = Favorite.where(user_id: current_user)

    elsif params[:query] == "" || (params.keys == ["controller", "action"]) && (params[:controller] == "projects" && params[:action] == "index") || (params[:location] == "" && params[:category] == "" && params[:favorite] == "" && params[:collaborator] == "" && params[:controller] == "projects" && params[:action] == "index")

      #we have grouped the different URLs with no content inside; in that case we want to return all the projects since there has not been any filter applied

      @projects = Project.all
      @user_favorites = Favorite.where(user_id: current_user)
    else

      #when we pass information in any of the parameters throught the project index filter we activate the filter
      #in case there is one or more params without values we select all the projects by default, otherwise we select the values passed

      @project_location = (params[:location].blank?) ? Project.all : Project.where(location: params[:location])
      @project_category = (params[:category].blank?) ? Project.all : Project.where(category_id: Category.all.where(name: params[:category]).ids.first)


      if params[:favorite].blank?
        @project_favorites =  Project.all
      elsif params[:favorite].to_i == 0
        @project_favorites = Project.left_joins(:favorites).where('favorites.project_id' =>  nil)
      else
        @project_favorites = Project.joins(:favorites).group("projects.id").having("COUNT (*) = ?", params[:favorite].to_i)
      end


      if params[:collaborator].blank?
        @project_collaborators = Project.all
      elsif params[:collaborator].to_i == 0
        @project_collaborators = Project.left_joins(:bookings).where('bookings.project_id' =>  nil)
      else
        @project_collaborators = Project.joins(:bookings).where('bookings.status' => 'Approved').group("projects.id").having("COUNT (*) = ?", params[:collaborator].to_i)
      end

      @projects = []
      @approved_bookings = 0

      #the filter will select all the projects that share the values defined in the filter (no value == all values)
      #it will check what projects are in the 4 different variables predefined before
      #in case there is a project that is shared across the 4 variables, it will display it


      @project_location.each do |project|
        if @project_category.include?(project) && @project_favorites.include?(project) && @project_collaborators.include?(project)
          @projects << project
        end
      end
      @user_favorites = Favorite.where(user_id: current_user)

    end

    #we create the filter options as follows
    #the idea is that we need to get all the different options available, per filter
    #in case there are duplicates, we need to earse them
    #finally, we need to sort the items in each array

    @locations = []
    Project.all.each do |project|
      @locations << project.location
    end
    @locations = @locations.uniq.sort

    @categories = []
    Category.all.each do |category|
      @categories << category.name
    end
    @categories = @categories.uniq.sort

    @favorites = []
    Project.all.each do |project|
      @favorites << project.favorites.count
    end
    @favorites = @favorites.uniq.sort

    @collaborators = []
    Project.all.each do |project|
      @collaborators << project.bookings.where(status: "Approved").count
    end
    @collaborators = @collaborators.uniq.sort

  end

  def show
    @project = Project.find(params[:id])
    @current_day = Time.now.day
    @current_month = Time.now.month
    @current_year = Time.now.year
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    @project.user_id = current_user.id
    if @project.save
      redirect_to dashboard_path

    else
      render :new
    end
  end

  def edit
    @project = Project.find(params[:id])
  end

  def update
    @project = Project.find(params[:id])
    if @project.update(project_params)
      redirect_to "/dashboard"
    else
      render :edit
    end
  end

  def destroy
    @project = Project.find(params[:id])
    @project.destroy
    redirect_to dashboard_path
  end

  private

  def project_params
    params.require(:project).permit(:title, :description, :location, :category_id, photos: [])
  end
end
