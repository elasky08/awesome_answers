class VotesController < ApplicationController
  before_action :authenticate_user!

  def create
    question      = Question.find params[:question_id]
    vote_params   = params.require(:vote).permit(:is_up)
    vote          = Vote.new vote_params
    vote.user     = current_user
    vote.question = question
    if vote.save
      redirect_to question_path(question), notice: "Voted!"
    else
      redirect_to question_path(question), alert: "Something is wrong!"
    end
  end

  def update
    question = Question.find params[:question_id]
    vote = Vote.find params[:id]
    vote_params = params.require(:vote).permit(:is_up)
    redirect_to question_path(question), notice: "Vote updated"
  end

  def destroy
    question = Question.find params[:question_id ]
    vote = Vote.find params[:id]
    vote.destroy
    redirect_to question, notice: "Vote removed"
  end

end
