class Rental < ApplicationRecord
  belongs_to :bicycle, optional: true
  belongs_to :renter, class_name: 'User'
  has_one :owner_review, ->(rental) { where(reviewer_user: rental.bicycle&.owner) }, #safe navigation (&.) operator
    class_name: 'Review', foreign_key: 'rental_id', dependent: :destroy
  has_one :renter_review, ->(rental) { where(reviewer_user: rental.renter) },
    class_name: 'Review', foreign_key: 'rental_id', dependent: :destroy

  enum rental_status: { in_progress: 0, completed: 1, cancelled: 2 }

  validate :date_not_already_booked, on: :create

  private

  def date_not_already_booked
    overlapping_rentals = Rental.where(bicycle_id: bicycle_id)
                                .where.not(id: id)
                                .where('start_date < ? AND end_date > ?', end_date, start_date)
    if overlapping_rentals.exists?
      errors.add(:base, 'Bicycle is already booked for these dates.')
    end
  end
end