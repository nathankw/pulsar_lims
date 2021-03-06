require 'elasticsearch/model'

class SequencingRun< ActiveRecord::Base
  include Elasticsearch::Model                                                                         
  include Elasticsearch::Model::Callbacks
  include ModelConcerns
  ABBR = "SRUN"
  DEFINITION = "Represents the realization of a Sequencing Request. The details of the actual sequencing run are provided here. A Sequencing Run belongs to a Sequencing Request, and has a Sequencing Result for each Libary on the Sequencing Request.  Model abbreviation: #{ABBR}"
  belongs_to :user
  belongs_to :sequencing_request
  belongs_to :report, class_name: "Document"
  belongs_to :data_storage
  belongs_to :submitted_by, class_name: "User"
  has_many   :sequencing_results, dependent: :destroy

  validates :status, presence: true, inclusion: {in: Enums::SEQUENCING_STATUS, message: "must be an element in the list #{Enums::SEQUENCING_STATUS}."}
  validates :data_storage_id, presence: {message: "must be set when the status is set to 'finished'.", if:  "status == 'finished'"}
  validates :name, presence: true
  validates_uniqueness_of :name, scope: :sequencing_request_id

  scope :persisted, lambda { where.not(id: nil) }
  accepts_nested_attributes_for :sequencing_results, allow_destroy: true
  accepts_nested_attributes_for :data_storage, allow_destroy: true

  def self.policy_class
    ApplicationPolicy
  end

  def get_barcodes_on_request(without_sequencing_result=false)
    barcodes = []
    sequencing_request.libraries.each do |lib|
      bc = lib.get_indexseq()
      if bc.present?
        if without_sequencing_result
          if not library_sequencing_result_present(lib)
            barcodes << bc
          end
        else
          barcodes << bc
        end
       end 
    end 
    return barcodes
  end

  def library_sequencing_result(library_id)
    return self.sequencing_results.find_by(library_id: library_id)
  end

  def library_sequencing_result_present(lib)
    return self.sequencing_results.where({library_id: lib.id}).present?
  end

  def get_libraries_without_sequencing_results
    res = []
    self.sequencing_request.libraries.each do |lib|
      if not self.library_sequencing_result_present(lib)
        res << lib
      end
    end
    return res
  end

  def params_for_url_for
    #Returns the argument that can be used for the url_for helper (see use in the welcome controller).
    #See https://github.com/nathankw/pulsar_lims/wiki/search.
    return [self.sequencing_request,self]
  end

end
