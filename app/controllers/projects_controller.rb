class ProjectsController < ApplicationController
  before_action :set_project, only: %i[ show edit update destroy ]

  # GET /projects
  def index
    @search = Project.ransack(params[:q])

    @search.sorts = 'id desc' if @search.sorts.empty?

    @projects = @search.result.page(params[:page])
  end

  # GET /projects/1
  def show
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  def create
    @project = Project.new(project_params)

    if @project.save
      flash.now.notice = "プロジェクトを登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /projects/1
  def update
    if @project.update(project_params)
      # redirect_toを明示しない場合は暗黙的に'render'が実行される
      flash.now.notice = "プロジェクトを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /projects/1
  def destroy
    @project.destroy!
    flash.now.notice = "プロジェクトを削除しました"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def project_params
      params.expect(project: [ :name ])
    end
end
