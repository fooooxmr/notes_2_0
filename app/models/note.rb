class Note < ApplicationRecord
  include AASM

  belongs_to :user

  validates :title, presence: true, uniqueness: true, length: { in: 2..20 }

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
end