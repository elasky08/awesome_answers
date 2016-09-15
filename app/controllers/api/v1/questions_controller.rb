class Api::V1::QuestionsController < Api::BaseController
  before_action :authenticate_api_user

  QUESTIONS_PER_PAGE = 20

  def index
    @questions2 = Question.search(params[:search_term])
    @questions = @questions2.order(created_at: :desc).
                          page(params[:page]).
                          per(QUESTIONS_PER_PAGE)

    # render json: @questions
  end

  def show
    question = Question.friendly.find params[:id]

    # in this case Rails will use app/serializers/question_serializer.rb
    # to generate the JSON. If no such file exists, Rails will revert to the
    # default way of converting ActiveRecord object to JSON.
    render json: question
  end

  def create
      question_params = params.require(:question).permit([:title, :body, { tag_ids: [] }, :image])
      question        = Question.new question_params
      question.user   = current_api_user
      if question.save
        render json: { success: true }
      else
        render json: { success: false, errors: question.errors.full_messages }
      end
    end
end
