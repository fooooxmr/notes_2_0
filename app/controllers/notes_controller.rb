class NotesController < ApplicationController
  before_action :authenticate_user!

  def index
    @notes = current_user.notes
  end

  def show
    @note = current_user.notes.find(params[:id])
  end

  def edit
    @note = current_user.notes.find(params[:id])
  end

  def update
    @note = current_user.notes.find(params[:id])
    if @note.update(permited_params)
      redirect_to note_path(@note)
    else
      render :edit
    end
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

  def permited_params
    params.require(:note).permit(:title, :description, :status)
  end
end