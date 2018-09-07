class ExportController < ApplicationController
  def create
    respond_to do |format|
      format.csv do
        export = NotesExportService.new
        export.collection = current_user.notes
        send_data export.to_csv
      end
    end
  end
end