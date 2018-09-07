class NotesExportService
  include LpCSVExportable::CanExportAsCSV
  column 'Title', model_method: :title
  column 'Description', model_method: :description
end