require 'elasticsearch/model'
class ChipBatchItem < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  include ModelConcerns
  ABBR = "CBI"
  DEFINITION = "Represents one of the Biosamples processed in this ChipBatch."
  #default_scope {order("lower(name)")} #no name column
  belongs_to :user
  belongs_to :biosample
  belongs_to :chip_batch
  belongs_to :concentration_unit, class_name: "Unit"

  validates :chip_batch_id, presence: true
  validates :biosample_id, presence: true
  validates :concentration, numericality: {greater_than: 0}, allow_blank: true
  validates :concentration_unit, presence: {message: "must be specified when the quantity is specified."}, if: "concentration.present?"
  validate :validate_concentration_units

  def self.policy_class
    ApplicationPolicy
  end

  private

  def validate_concentration_units
    if self.concentration_unit.present?
      if self.concentration.blank?
        self.concentration_unit = nil
        return
      end
      if self.concentration_unit.unit_type != "concentration"
        self.errors.add(:concentration_unit_id, "must be a concentration type of unit.")
        return false
      end
    end
  end

end
