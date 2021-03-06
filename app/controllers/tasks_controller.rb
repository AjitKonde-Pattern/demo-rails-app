class TasksController < ApplicationController
  def index
    @todo   = Task.where(:done => false)
    @task   = Task.new
    @lists  = List.all
    @list   = List.new
    @taskslist = List.all
    respond_to do |format|
      format.html
      format.json do
        render :json => {:tasks => Task.all.map(&:to_json) }
      end
    end
  end

  def create
    @list = List.find(params[:list_id])
    task_params = params[:task].is_a?(String) ? JSON.parse(params[:task]) : params[:task]
    task_params = secure_user_input(task_params)
    task_new_param = params[:task]
    @task = @list.tasks.new(task_params)
    if @task.save
      status = "success"
      flash[:notice] = "Your task was created."
    else
      status = "failure"
      flash[:alert] = "There was an error creating your task."
    end
    respond_to do |format|
      format.html do
        redirect_to(list_tasks_url(@list))
      end
      format.json do
        render :json => {:status => status, :task => @task.to_json}
      end
    end
  end

  def update
    @list = List.find(params[:list_id])
    @task = @list.tasks.find(params[:id])
    task_params = secure_user_input(params[:task])
    respond_to do |format|
      if @task.update_attributes(task_params)
        format.html { redirect_to( list_tasks_url(@list), :notice => 'Task was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @list = List.find(params[:list_id])
    @task = Task.find(params[:id])
    @task.destroy

    respond_to do |format|
      format.html { redirect_to(list_tasks_url(@list)) }
    end
  end

  protected
  def secure_user_input(task_params)
    task_params[:name] = task_params[:name].replace(CGI::escapeHTML(task_params[:name])) if task_params[:name].present?
    task_params
  end
end
