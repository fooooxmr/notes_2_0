class NotesController < ApplicationController
  def index
    search_type = params[:search].present? ? 'must' : 'should'
    @notes = if params[:search].present? || params[:status].present?
               Note.search_notes(underscore(params[:search]),
                                 underscore(params[:status]),
                                 underscore(params[:sort]),
                                 current_user,
                                 search_type).records
             else
               current_user.notes
    end
  end

  def show
    @note = current_user.notes.find(params[:id])
  end

  def edit
    @note = current_user.notes.find(params[:id])
  end

  def update
    @note = current_user.notes.find(params[:id])
    if @note.update(permited_params.merge(updated_at: Time.now))
      redirect_to note_path(@note)
    else
      render :edit
    end
  end

  def destroy
    Note.find(params[:id]).delete
    redirect_to notes_path
  end

  def new
    @note = Note.new
  end

  def create
    @note = Note.new(permited_params.merge(user: current_user))
    if @note.save
      redirect_to notes_path
    else
      render :new
    end
  end

  private

  def underscore(str)
    str&.parameterize&.underscore
  end

  def permited_params
    params.require(:note).permit(:title, :description, :status)
  end
end