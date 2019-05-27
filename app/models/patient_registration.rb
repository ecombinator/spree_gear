class PatientRegistration < Spree::User
  validates :name, presence: true
  validates :legitimate, acceptance: true
  validates :identification, presence: true
end
