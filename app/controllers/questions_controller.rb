class QuestionsController < ApplicationController
  before_action :load_question, only: [:show, :edit, :update, :destroy]
  before_action :authorize_user, except: [:create]

  # GET /questions/1/edit
  def edit
  end

  # POST /questions
  # POST /questions.json
  def create
    @question = Question.new(question_params)
    @question.author = current_user

    if check_captcha(@question) && @question.save
      @question.add_hashtags
      redirect_to user_path(@question.user), notice: 'Вопрос задан!'
    else
      render :edit
    end
  end

  def update
    if @question.update(question_params)
      @question.add_hashtags
      redirect_to user_path(@question.user), notice: 'Вопрос сохранен!'
    else
      render :edit
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.json
  def destroy
    user = @question.user
    @question.destroy
    redirect_to user_path(user), notice: 'Вопрос удален :('
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def load_question
      @question = Question.find(params[:id])
    end

    def authorize_user
      reject_user unless @question.user == current_user
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def question_params
      if current_user.present? && params[:question][:user_id].to_i == current_user.id
        params.require(:question).permit(:user_id, :text, :answer)
      else
        params.require(:question).permit(:user_id, :text)
      end
    end

    private

    def check_captcha(model)
      if current_user.present?
        true
      else
        verify_recaptcha(model: model)
      end
    end
end
