require 'elasticsearch/model'
class Barcode < ActiveRecord::Base
  include Elasticsearch::Model                                                                         
  include Elasticsearch::Model::Callbacks
  include ModelConcerns
  ABBR = "BC"
  DEFINITION = "A single, contiguous barcode sequence that belongs to a Sequencing Library Prep Kit. Can be either an index1 barcode or an index2 barcode in the case of paired-end sequencing.  Model abbreviation: #{ABBR}"
  has_many :libraries

  belongs_to :user
  belongs_to :sequencing_library_prep_kit

  validates :index_number, presence: true, inclusion: { in: [1,2],  message: "must be one of [1,2]"}
  validates_uniqueness_of :name, scope: :sequencing_library_prep_kit_id
  validates :name, presence: true
  validates_uniqueness_of :sequence, scope: :sequencing_library_prep_kit_id
  validates :sequence, presence: true, format: { with: /\A[acgtnACGTN,]+\z/, message: "can only contain characters in the set ACTGN. Multi-oligo barcodes (i.e. 10x Genomics sample indices in single cell sequencing libraries) are allowed and must be separated by a comma." }
  validates :sequencing_library_prep_kit, presence: true

  scope :persisted, lambda { where.not(id: nil) }
  scope :kit, lambda {|kit_id| where(sequencing_library_prep_kit_id: kit_id)}

  def to_label
     # Shadows the to_label method defined in /app/models/concerns/model_concerns. 
      return "#{self.name} + #{self.sequence}"
  end

  def self.policy_class
    ApplicationPolicy
  end

  def params_for_url_for
    #See https://github.com/nathankw/pulsar_lims/wiki/search.
    return [self.sequencing_library_prep_kit,self]
  end

  def to_s
    display()
  end

  def display
    val = "#{self.sequence}"
    if self.name == self.sequence
      val = self.sequence
    end
    return val
  end

  def sequence=(sequence)
    write_attribute(:sequence,sequence.upcase())
  end

end
