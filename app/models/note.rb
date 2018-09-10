class Note < ApplicationRecord
  include AASM
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  SORT_FIELDS = %w(created_at updated_at).freeze

  belongs_to :user

  scope :ready_for_export, ->{ where(status: :ready_for_export) }

  validates :title, presence: true, length: {in: 2..20}

  settings do
    mappings dynamic: true do
      indexes :title, type: :string
      indexes :description, type: :string
      indexes :status, type: :string
      indexes :updated_at, type: :date
      indexes :created_at, type: :date
      indexes :user_id, type: :integer
    end
  end

  aasm column: :status do
    state :draft, initial: true
    state :ready_for_export
    state :exported

    event :prepare_for_export do
      transitions from: [:draft], to: :ready_for_export
    end

    event :drafted do
      transitions from: [:ready_for_export], to: :draft
    end

    event :export do
      transitions from: [:ready_for_export], to: :exported
    end
  end

  def self.statuses
    self.aasm.states.map(&:to_s)
  end

  def self.to_export(notes_ids, current_user)
    notes_ids.split.map do |note_id|
      note = find_by(id: note_id, user_id: current_user.id)
      note.export!
      note
    end.compact
  end

  def as_indexed_json(options = nil)
    {
        'title' => title,
        'description' => description,
        'status' => status,
        'created_at' => created_at,
        'updated_at' => updated_at,
        'user_id' => user_id
    }
  end

  def self.search_notes(query, status, order_field, user, search_type)
    search({
               query: {
                   bool: {
                       search_type => [
                           {
                               multi_match: {
                                   query: query,
                                   fields: [:title, :description]
                               }
                           }],
                       filter: [{
                          term: {user_id: user.id},
                          term: {status: status}
                       }]
                   }
               },
               sort: [{
                  order_field => {order: :desc}
               }]
           })
  end
end