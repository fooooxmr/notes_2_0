class ExportController < ApplicationController
  def create
    respond_to do |format|
      format.csv do
        export = NotesExportService.new
        export.collection = Note.to_export(params[:notes], current_user)
        send_data export.to_csv
      end
    end
  end
end