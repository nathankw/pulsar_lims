require 'elasticsearch/model'
class BiosampleReplicate < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  include ModelConcerns
  ABBR = "BR"
  DEFINITION = "A replicate of a biosample, used in experiments such as a Chipseq experiment."
  belongs_to :biosample
  belongs_to :chipseq_experiment
  has_many   :chipseq_experiments, foreign_key: :wild_type_input_id, dependent: :nullify
  belongs_to :user
  has_many :documents

  validates :biosample, presence: true
  validates :biological_replicate_number, presence: true
  validates :technical_replicate_number, presence: true
  validate :validate_replicates 
    # Make sure that this biosample can only have multiple technical biosample_replicates,
    # and not multiple biosample replicates of the same object type. Also make sure that all replicates
    # of a given experiment are on the same experiment. 
  validate :validate_wild_type_input

  scope :persisted, lambda { where.not(id: nil) }

  def self.policy_class
    ApplicationPolicy
  end

  def display
    self.biosample.name + " [#{self.biological_replicate_number},#{self.technical_replicate_number}]"
  end

  private

  def validate_replicates
    # validates that if a Biosample is going to have multiple BiosampleReplicates, that they are all
    # technical replicates whereby each BiosampleReplicate's biological_replicate_number attribute is
    # the same, but varies with regard to the technical_replicate_number attribute. They must also all
    # be on the same ChipseqExperiment object.
    brn = self.biological_replicate_number
    trn = self.technical_replicate_number
    chipseq_exp_id = self.chipseq_experiment_id
    self.biosample.biosample_replicates.persisted.each do |rep|
      next if self.id == rep.id
      if chipseq_exp_id != rep.chipseq_experiment_id
        self.errors.add(:chipseq_experiment_id, "must be the same value as other replicates of the same biosample.")
      end
      if brn != rep.biological_replicate_number
        self.errors.add(:biological_replicate_number, "must be the same as any existing BiosampleReplicate objects associated with the selected Biosample. This is because a Biosample can only be associated to one biological replicate in the technical sense. It can, however, have multiple technical replicates, in which case each associated BiosampleReplicate object must have the same number set for the 'biological_replicate_number' attribute, but a different value for each 'technical_replicate_number' attribute.")
      end
      if trn == rep.technical_replicate_number
        self.errors.add(:technical_replicate_number, "must be set to a different value than other technical replicates associated to the same biosample.")
      end
    end
  end

  def validate_wild_type_input
    # If the user checks the wild_type_input attribute, then 
    # make sure that the control attribute is set to true since wt inputs are a type of controls.
    if self.wild_type_input
      self.control = true
    end
  end
end