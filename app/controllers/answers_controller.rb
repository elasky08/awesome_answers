class AnswersController < ApplicationController
  def create
    # we instantiate a new answer object based on the params we got from the user. We use: params.require(:answer).permit(:body) as it's required part of Rails for security reason (strong Parameters)
    @answer = Answer.new params.require(:answer).permit(:body)

    # We fetch the question by its id which came from the URL. In the form in the question/show.html.erb we used a url: question_answers_path(@question) this path includes a variable :question_id which comes as part of the params
    @q = Question.friendly.find params[:question_id]

    # We associate the answer we defined above with the question we found above as well. This is because we need to associate the created answer with the question
    @answer.question = @q

    respond_to do |format|

    # we save the answer to the database
    # answer.save
    # render json: params

    # we redirect to the question show page
    # redirect_to question_path(question), notice: "Answer created!"

    # we same the answer to the database
      if @answer.save
        AnswerMailer.notify_question_owner(@answer).deliver_later
        # we redirect to the question show page
        format.html {redirect_to question_path(@q), notice: "Answer created!"}
        format.js {render :create_success} # point to views/answers/create_success.html.erb
      else
        flash[:alert] = "Please fix errors below"
        format.html {render "/questions/show"}
        format.js {render :create_failure}
      end

    end
  end

  def destroy
    q = Question.friendly.find params[:question_id]
    # a = Answer.find params[:id]
    # a.destroy
    @answer = Answer.find params[:id]
    @answer.destroy

    respond_to do |format|
      # render json: params
      format.html {redirect_to question_path(q), notice: "Answer deleted"}
      format.js {render} # if you just say 'render' this will look for app/views/answers/destroy.js.erb
    end
  end

end
