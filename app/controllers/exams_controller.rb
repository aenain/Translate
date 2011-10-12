class ExamsController < ApplicationController
  def new
    @exam = Exam.new
  end

  def create
    session.delete(:current_exam_id)
    @exam = Exam.new(params[:exam])

    if @exam.save
      session[:current_exam_id] = @exam.id
      redirect_to @exam
    else
      render :new
    end
  end

  def show
    @exam = Exam.find(session[:current_exam_id] || params[:id])
    @entry = @exam.entries.awaiting.first

    redirect_to summary_exam_path if @entry.nil?
  end

  def summary
    session.delete(:current_exam_id)
    @exam = Exam.find(params[:id])
    @wrong_entries = @exam.entries.wrong.includes(:question)
  end

  def answer
    @entry = ExamEntry.find(params[:exam_entry][:id])
    @result = @entry.try_answer(params[:exam_entry][:answer])

    if @entry.last?
      if request.xhr?
        render :json => { redirect: summary_exam_url(@entry.exam) }
      else
        redirect_to summary_exam_path(@entry.exam)
      end
    else
      @next_entry = @entry.lower_item

      if request.xhr?
        render :json => { result: @result,
                          entry: @next_entry,
                          question: @next_entry.question.for_js }
      else
        render :nothing => true
      end
    end
  end
end