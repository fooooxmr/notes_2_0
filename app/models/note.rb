class Note < ApplicationRecord
  include AASM
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  SORT_FIELDS = %w(created_at updated_at).freeze

  belongs_to :user

  validates :title, presence: true, length: {in: 2..20}

  settings dynamic: false do
    mappings dynamic: 'true' do
      indexes :title, type: 'string'
      indexes :description, type: 'string'
      indexes :status, type: 'string'
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
      transitions from: [:ready_for_export], to: :export
    end
  end

  def self.statuses
    self.aasm.states.map(&:to_s)
  end

  def self.search_notes(query, status, user, search_type)
    search({
               query: {
                   bool: {
                       "#{search_type}": [
                           {
                               multi_match: {
                                   query: query,
                                   fields: [:title, :description]
                               }
                           },
                           {
                               match: {
                                   user_id: user.id
                               }
                           }],
                       filter: {
                           term: {
                               status: status
                           }
                       }
                   }
               }
           })
  end
end