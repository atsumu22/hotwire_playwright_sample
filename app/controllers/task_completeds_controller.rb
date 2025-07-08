class TaskCompletedsController < ApplicationController
  before_action :set_project
  def update
    @task = @project.tasks.find(task_completed_params[:task_id])

    @task.update(status: task_completed_params[:status] == '1')
  end

  private
    def set_project
      @project = Project.find(params[:project_id])
    end
    # Use callbacks to share common setup or constraints between actions.

    # Only allow a list of trusted parameters through.
    def task_completed_params
      params.expect(task_completed: [ :status, :task_id ])
    end
end

