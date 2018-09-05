class NotesController < ApplicationController
  before_action :authenticate_user!

  def index
    render inline: "Hello world"
  end
end