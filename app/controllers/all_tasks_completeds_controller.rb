class AllTasksCompletedsController < ApplicationController
  before_action :set_project
  def update
    sleep 3
    @project.tasks.update_all(status: true)
    @tasks = @project.tasks.order(:sort_order)
  end

  private
    def set_project
      @project = Project.find(params[:project_id])
    end
end

