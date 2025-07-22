class TasksController < ApplicationController
  before_action :set_project
  before_action :set_task, only: %i[ show edit update destroy ]

  # GET /tasks
  def index
    @tasks = @project.tasks
  end

  # GET /tasks/1
  def show
  end

  # GET /tasks/new
  def new
    @task = @project.tasks.build
    render turbo_stream: turbo_stream.update("modal_content_frame", partial: "tasks/form", locals: { project: @project, task: @task })
  end

  # GET /tasks/1/edit
  def edit
    render turbo_stream: turbo_stream.update("modal_content_frame", partial: "tasks/form", locals: { project: @project, task: @task })
  end

  # POST /tasks
  def create
    @task = @project.tasks.build(task_params)

    respond_to do |format|
      if @task.save
        format.html { redirect_to @project, notice: "タスクが作成されました。" } # 通常のHTMLリクエストにも対応
        format.turbo_stream do
          # ここで、create.turbo_stream.erb の内容を直接書くか、
          # あるいは create.turbo_stream.erb ファイルがあれば、そちらが自動でレンダリングされる
          render turbo_stream: [ # 明示的に Turbo Stream レスポンスを構築
            turbo_stream.append("project-tasks", partial: "tasks/task", locals: { task: @task }),
            # Rails 8 なので、これでOKよ！カスタムヘルパーは不要。
            turbo_stream.action("stimulus_dispatch", { controller: "modal", action: "close" }),
            turbo_stream.prepend("notice", "<p class='text-green-500'>タスクを追加しました。</p>")
          ]
        end
      else
        # 保存失敗時は、フォームを再表示
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("modal_content_frame", partial: "tasks/form", locals: { project: @project, task: @task })
          ], status: :unprocessable_entity
        end
      end
    end
  end

  # PATCH/PUT /tasks/1
  def update
    if @task.update(task_params)
      flash.now.notice = "タスクを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /tasks/1
  def destroy
    @task.destroy!
    flash.now.notice = "タスクを削除しました"
  end

  private
    def set_project
      @project = Project.find(params[:project_id])
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @task = @project.tasks.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def task_params
      params.expect(task: [ :title, :status, :sort_order, :project_id ])
    end
end
