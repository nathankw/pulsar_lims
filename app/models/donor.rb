class Donor < ActiveRecord::Base
  include ModelConcerns
	ABBR = "DON"
	DEFINITION = "The donor of a biosample, whether human or some other type of organism. For available identifiers of human donors, see https://www.encodeproject.org/human-donors.  Model abbreviation: #{ABBR}"
	has_many :biosamples, dependent: :restrict_with_error
	belongs_to :user

	validates :upstream_identifier, uniqueness: true, presence: true
	validates :name, length: { minimum: 2, maximum: 40 }, uniqueness: true
  validates :gender, inclusion: {in: Enums::GENDERS, message: "Must be an element from the list #{Enums::GENDERS}"}

	scope :persisted, lambda { where.not(id: nil) }

	def self.policy_class
		ApplicationPolicy
	end 
end
