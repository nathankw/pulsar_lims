require 'elasticsearch/model'

class SequencingRequest < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  include ModelConcerns
  ABBR = "SREQ"
  DEFINITION = "Represents the type of sequencing that you will have done on one or more Libraries together. When more than one Library is added to a given Sequencing Request, then this also represents a pooled Library to be sequenced.  Model abbreviation: #{ABBR}"
  #There is a unique index on the compound key in the libraries_sequencing_requests join table, disallowing
  # the same library to be added twice.
  has_and_belongs_to_many :libraries
  has_and_belongs_to_many :plates, after_remove: :remove_plate_libraries
  belongs_to :concentration_unit, class_name: "Unit"
  belongs_to :sequencing_platform
  belongs_to :sequencing_center
  belongs_to :submitted_by, class_name: "User"
  has_many    :sequencing_runs, dependent: :destroy
  belongs_to :user

  validates :name, uniqueness: true, allow_blank: true
  validates :sequencing_center, presence: true
  validates :sequencing_platform, presence: true
  validates :concentration, presence: {message: "must be specified."}, if: "concentration_unit.present? or concentration_instrument.present?"
  validates :concentration_unit, presence: {message: "must be specified."}, if: "concentration.present? or concentration_instrument.present?"

  accepts_nested_attributes_for :libraries, allow_destroy: true
  accepts_nested_attributes_for :plates, allow_destroy: true

  scope :persisted, lambda { where.not(id: nil) }
  validate :validate_unique_barcodes
  validate :validate_libs_have_same_kit
  validate :validate_concentration_unit

  def self.policy_class
    ApplicationPolicy
  end

  def s3_direct_post
    # Used for getting a bucket object URI for uploading an Illumina SampleSheet.
    # Called in the controller via a private method with the same name.
    return S3_BUCKET.presigned_post(key: "sample_sheets/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
  end

  def s3_submission_sheet_direct_post
    return S3_BUCKET.presigned_post(key: "submission_sheets/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
  end


  def plate_ids=(ids)
    return unless ids.present?
    ids.each do |i|
      next if i.blank?
      plate = Plate.find(i)
      next if self.plates.include?(plate)
      self.plates << plate
      self.add_libraries_from_plate(plate)
    end
  end

  def library_ids=(ids)
    return unless ids.present?
    ids.each do |i|
      next if i.blank?
      lib = Library.find(i)
      next if self.libraries.include?(lib)
      self.libraries << lib
    end
  end

  def get_barcodes(sequences=false)
    #Args : sequences - boolean. If true, then an array of barcode sequences is returned rather
    # then the objects.
    barcodes = []
    libraries.each do |lib|
      bc = lib.get_indexseq()
      if bc.present?
        if sequences
          bc = bc.sequence
        end
        barcodes << bc
      end
    end
    return barcodes
  end

  def get_library_with_barcode(barcode_id)
    self.libraries.each do |lib|
      if (lib.paired_barcode_id == barcode_id) or (lib.barcode_id == barcode_id)
        return lib
      end
    end
  end

  def get_library_barcode_sequence_hash()
    # Creates a hash where each key is a Library ID whose value is the barcode sequence on the 
    # library. This is done for each Library on the SequencingRequest.
    res = {}
    self.libraries.each do |lib|
      res[lib.id] = lib.get_indexseq.sequence()
    end
    return res
  end

  protected
    def add_libraries_from_plate(plate)
      #I Set this method under the protected block so that this can be called from an instance method within the class definition.
      # Originally I had this under the private block, but that didn't allow for instance methods in the class definition
      # to call it.
      plate.wells.each do |w|
        next if w.fail?
        lib = w.get_library()
        if lib.nil?
          raise "Error adding plates to sequencing request: No library found for well '#{w.name}' on plate '#{plate.name}' - can't be added to sequening request. If you intend to have this well empty, then go into the well and mark is as failed."
        else
          self.libraries << w.get_library()
        end
      end
    end

  private

    def validate_concentration_unit
      if self.concentration_unit.present?
        if self.concentration_unit.unit_type != "concentration"
          self.errors.add(:concentration_unit_id, "must be a concentration type of unit.")
          return false
        end
      end
    end

    def remove_plate_libraries(plate)
      #Gets called after an associated plate is removed so that its libraries, which were added to self.libraries, can be also removed
      # from the sequencing_request.
      plate.get_libraries().each do |lib|
        if self.libraries.include?(lib)
          self.libraries.destroy(lib)
        end
      end
    end

    def validate_unique_barcodes
      seqs = self.get_barcodes(sequences=true)
      dups = {}
      seqs.uniq.each do |s|
        count = seqs.count(s)
        if count > 1
          dups[s] = count
        end
      end
      if dups.present?
        self.errors[:base] << "Duplicate barcodes detected. Their counts are: #{dups.to_json}"
        #raise "Duplicate barcodes detected: #{dups.to_json}"
      end
    end

    def validate_libs_have_same_kit
      libs = self.libraries
      return unless libs.any?
      prev_kit_name = libs.first.sequencing_library_prep_kit.name
      count = -1
      libs.each do |lib|
        count += 1
        kit_name = lib.sequencing_library_prep_kit.name
        if kit_name != prev_kit_name
          self.errors[:base] << "Multiple library prep kits are present. For example, library #{lib.name} was prepared with #{kit_name}, whereas libary #{libs[count -1].name} was prepared with #{prev_kit_name}."
          return false
          #raise "Multiple library prep kits are present. For example, library #{lib.name} was prepared with #{kit_name}, whereas libary #{libs[count -1].name} was prepared with #{prev_kit_name}."
        end
        prev_kit_name = kit_name
      end
    end
end
