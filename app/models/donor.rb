class Donor < ActiveRecord::Base
	ABBR = "DON"
	DEFINITION = "The donor of a biosample, whether human or some other type of organism. For available identifiers of human donors, see https://www.encodeproject.org/human-donors.  Model abbreviation: #{ABBR}"
	has_many :biosamples
	belongs_to :user

	validates :upstream, uniqueness: true, presence: true
	validates :name, length: { minimum: 2, maximum: 40 }, uniqueness: true

	scope :persisted, lambda { where.not(id: nil) }

	def self.policy_class
		ApplicationPolicy
	end 
end
