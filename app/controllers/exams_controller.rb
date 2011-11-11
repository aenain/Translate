class ExamsController < ApplicationController
  before_filter :load_exam, only: [:summary, :wrong_answers_listing]

  def new
    @exam = Exam.new(start_at: Word.first.created_at.to_date, stop_at: Word.last.created_at.to_date, lang: Language::FOREIGN.first)

    @start_date = Word.first.created_at.to_date
    @days = (Date.today - @start_date).to_i
    @days = 1 if @days.zero?
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

    if @entry.nil?
      redirect_to summary_exam_path
    else
      @how_many_left = @exam.entries.last.position - @entry.position + 1
    end
  end

  def summary
    session.delete(:current_exam_id)
    @wrong_entries = wrong_entries_by_page(1)
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
                          question: @next_entry.question.for_js,
                          how_many_left: @entry.exam.entries.last.position - @entry.position }
      else
        render :nothing => true
      end
    end
  end

  def estimate_words_count
    start_at = Date.parse(params[:exam][:start_at])
    stop_at = Date.parse(params[:exam][:stop_at])

    @count = Exam.estimate_words_count(languages: [Language::PRIMARY, params[:exam][:lang]], creation_dates: start_at..stop_at)
    render :json => { count: @count }
  end

  def wrong_answers_listing
    @wrong_entries = wrong_entries_by_page(params[:page])
    render :partial => 'wrong_answers'
  end

  private

  def load_exam
    @exam = Exam.find(params[:id])
  end

  def wrong_entries_by_page(page)
    @page = page && page.to_i || 1
    @exam.entries.wrong.includes(:question).paginate(page: @page, per_page: 1)
  end
end