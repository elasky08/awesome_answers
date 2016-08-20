class QuestionsController < ApplicationController
  # before_action takes in an argument for a method (ideally private) that gets executed just before the action and it's still within the request/response
  before_action :find_question, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:create, :edit, :destroy, :update, :new]
  # before_action :find_question, except: [:show, :edit, :update, :destroy]
  # GET /question/new
  QUESTIONS_PER_PAGE = 10

  def new
    # we need to instantiate a new Question object because it will help us build
    # a form to create a question easily
    @question = Question.new

    # render :new
    # render "/questions/new"
  end

  def create
    # {"utf8":"✓","authenticity_token":"pmMdPyJfOg3kvp+oUPnpgqr40Oq2PJHdTY1SBrulYhesuh+aphVdvFZybUEn/fFJNm/bJu/V/8TOT94z2PpX7g==","question":{"title":"asdasd","body":"ddddd"},"commit":"Create Question","controller":"questions","action":"create"}
    #we are using the 'strong parameters' feature to rails here to allow mass-assigning the attributes that we want to allow the user to set
    # question_params = params[:question] #{"title":"asdasd","body":"ddddd"}
    # question_params = params.require(:question).permit([:title, :body]) => now it's in a method
    # Question.create question_params
    @question       = Question.new question_params
    @question.user  = current_user
    if @question.save
      # render json: params
      # render :show
      # redirect_to question_path({id: @question.id}) => long form of below code
      # redirect_to question_path({id: @question})

      redirect_to question_path(@question), notice: "Question created successfully"
      # flash[:notice] = "Question created successfully" #this is the same as sessions[:notice] but flash[:notice] will only show once and after you refresh the page, the flash will be gone
      # redirect_to question_path(@question)
    else
      # flash[:alert] = @question.errors.full_messages.join(", ") => you can hardcode
      flash[:alert] = "Please fix errors below before saving"
      render :new
    end
  end

  def show
    @q = Question.find params[:id]
    @answer = Answer.new
  end

  def index
    @questions = Question.order(created_at: :desc).
                          page(params[:page]).
                          per(QUESTIONS_PER_PAGE)
  end

  def edit
    # @question = Question.find params[:id] => now it's in the method
  end

  def update
    # @question = Question.find params[:id]
    if @question.update question_params
      redirect_to question_path(@question)
    else
      render :edit
    end
  end

  def destroy
    # question = Question.find params[:id]
    @question.destroy
    redirect_to questions_path
  end

  private

  def find_question
    @question = Question.find params[:id]
  end

  def question_params
    # we're using the `strong parameters` feature of Rails here to only allow
    # mass-assigning the attributes that we want to allow the user to set
    params.require(:question).permit([:title, :body])
  end

end
