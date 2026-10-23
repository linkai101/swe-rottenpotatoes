class MoviesController < ApplicationController
  before_action :set_movie, only: %i[ show edit update destroy ]

  # GET /movies or /movies.json
  def index
    # landing here without any settings (e.g. "Back to movies"): restore the
    # remembered ones through the URL so it stays RESTful
    if !(params.key?(:ratings) || params.key?(:sort_by)) &&
       (session[:ratings].present? || session[:sort_by].present?)
      flash.keep
      return redirect_to movies_path(ratings: session[:ratings].to_a.index_with { "1" }.presence,
                                     sort_by: session[:sort_by])
    end

    @all_ratings = Movie.all_ratings
    selected = params[:ratings].present? ? params[:ratings].keys : []
    # no boxes checked (or first visit) means show everything, all boxes checked
    @ratings_to_show = selected.presence || @all_ratings
    # only sort on known columns, since the value comes from the user
    @sort_by = params[:sort_by] if Movie.sortable_columns.include?(params[:sort_by])
    # explicitly submitted settings replace the remembered ones
    # (unchecking everything is saved as an empty list, i.e. show all)
    if params.key?(:ratings) || params.key?(:sort_by)
      session[:ratings] = selected
      session[:sort_by] = @sort_by
    end
    @movies = Movie.with_ratings(selected)
    @movies = @movies.order(@sort_by) if @sort_by
  end

  # GET /movies/1 or /movies/1.json
  def show
  end

  # GET /movies/new
  def new
    @movie = Movie.new
  end

  # GET /movies/1/edit
  def edit
  end

  # POST /movies or /movies.json
  def create
    @movie = Movie.new(movie_params)

    respond_to do |format|
      if @movie.save
        format.html { redirect_to @movie, notice: "Movie was successfully created." }
        format.json { render :show, status: :created, location: @movie }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @movie.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /movies/1 or /movies/1.json
  def update
    respond_to do |format|
      if @movie.update(movie_params)
        format.html { redirect_to @movie, notice: "Movie was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @movie }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @movie.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /movies/1 or /movies/1.json
  def destroy
    @movie.destroy!

    respond_to do |format|
      format.html { redirect_to movies_path, notice: "Movie was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_movie
      @movie = Movie.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def movie_params
      params.require(:movie).permit(:title, :rating, :description, :release_date)
    end
end
