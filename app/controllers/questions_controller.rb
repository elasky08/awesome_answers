class QuestionsController < ApplicationController
  # before_action takes in an argument for a method (ideally private) that gets executed just before the action and it's still within the request/response
  before_action :find_question, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:create, :edit, :destroy, :update, :new]
  before_action :authorize!, only: [:destroy, :update, :edit]
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
    question_params = params.require(:question).permit([:title, :body, { tag_ids: [] },:image, :tweet_it])
    @question       = Question.new question_params
    @question.user  = current_user
    if @question.save
      if @question.tweet_it
          client = Twitter::REST::Client.new do |config|
            config.consumer_key        = ENV["TWITTER_API_KEY"]
            config.consumer_secret     = ENV["TWITTER_API_SECRET"]
            config.access_token        = current_user.twitter_token
            config.access_token_secret = current_user.twitter_secret
          end
          client.update "#{@question.title} #{question_url(@question)}"
      end
      # render json: {success: true}
      redirect_to question_path(@question), notice: "Question created successfully."
    elsif
      render json: {success: false, errors: @question.errors.full_messages}
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
    @q = Question.friendly.find params[:id]
    @q2 = Question.search(params[:search_term])
    @qs = @q2.order(created_at: :desc).
              page(params[:page]).
              per(QUESTIONS_PER_PAGE)
    @answer = Answer.new
  end

  def index
    @questions2 = Question.search(params[:search_term])
    @questions = @questions2.order(created_at: :desc).
                          page(params[:page]).
                          per(QUESTIONS_PER_PAGE)

    respond_to do |format|
      format.html {render}
      format.json {render json: @questions}
    end
  end

  def edit
    # @question = Question.find params[:id] => now it's in the method
  end

  def update
    @question.slug = nil
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

  def search
    if params[:search_term]
      query = "%#{params[:search_term]}%"
      @questions = Question.where("title ILIKE :search_term OR body ILIKE :search_term", {search_term: query})
    else
      @questions = Question.all
    end
      render :index
  end

  private

  def find_question
    @question = Question.friendly.find params[:id]
  end

  def question_params
    # we're using the `strong parameters` feature of Rails here to only allow
    # mass-assigning the attributes that we want to allow the user to set
    params.require(:question).permit([:title, :body, {tag_ids: []}, :image])
  end

  def authorize!
    redirect_to root_path, alert: "access denied" unless @question.user == current_user
  end

end
