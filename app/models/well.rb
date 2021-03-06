require 'elasticsearch/model'

class Well < ActiveRecord::Base
  include Elasticsearch::Model                                                                         
  include Elasticsearch::Model::Callbacks
  include ModelConcerns
  ABBR = "WELL"
  DEFINITION = "A well of a plate, such as a PCR plate or any other plate that holds individual samples in the lab.  Model abbreviation: #{ABBR}"
  #has_one :biosample, dependent: :destroy #i.e. in single cell experiments. Each sorted cell is a biosample in a well.
  has_one :biosample, dependent: :destroy, validate: true
  belongs_to :user
  belongs_to :plate

  validates :row, presence: true
  validates :col, presence: true
  validates_uniqueness_of :row, scope: [:plate_id, :col]
  validates_uniqueness_of :name, scope: :plate_id
  validate :validate_location

  scope :persisted, lambda { where.not(id: nil) }
  before_validation :set_name
  after_create  :add_biosample

  def self.policy_class
    ApplicationPolicy
  end

  def get_name 
    return "#{Plate::row_letter(self.row)}#{col}"
  end

  def get_library
    # Biosamples can have many Libraries. A Biosample on a Well, however, has different application
    # semantics. Such a Biosample should only have a single Library; if more than only the first is
    # considered here. 
    if self.biosample.blank? or self.biosample.libraries.blank?
      return nil
    end
    return self.biosample.libraries.first
  end

  def add_library_to_biosample(biosample)
    # This method should only be called for wells belonging to plates on single_cell_sorting experiments. 
    if not biosample.well.id == self.id
      raise "Invalid biosample #{biosample.name} does not exist on the same Plate as does this Well #{well.name}."
    end
    library_attrs = self.plate.single_cell_sorting.library_prototype.clone()
    library = biosample.libraries.create(library_attrs)
    #I first tried using create_biosample!, which did raise ActiveRecord:RecordInvalid. However,
    # while that does issue a Rollback as expected as any exception would in a callback, the form errors appear to be gone
    # and don't display on the form. Thus, the user is left with a re-rendered and populated form w/o any indication
    # of what happened.
    if not library.valid?
      raise "Unable to create library for biosample #{biosample.name}: #{library.errors.full_messages}"
      #throws a RuntimeError 
    end 
  end

  def params_for_url_for
    #Returns the argument that can be used for the url_for helper (see use in the welcome controller).
    #See https://github.com/nathankw/pulsar_lims/wiki/search. 
    return [self.plate,self]
  end

  private

  def validate_location
    row = self.row
    col = self.col
    row_valid = (row > 0) && (row <= self.plate.nrow)
    if not row_valid
      self.errors[:row] << "Must be > 0 and <= the number of rows on the plate."
      return false
    end
    col_valid = (col > 0) && (col <= self.plate.ncol)
    if not col_valid
      self.errors[:col] << "Must be > 0 and <= the number of columns on the plate."
      return false
    end
    return true
  end

  def add_biosample
    # An after create hook to add a Biosample to the well, but only if the plate that this well 
    # belongs to is a part of a SingleCellSorting.
    if not self.plate.single_cell_sorting.present?
      return
    end
    custom_attrs = {}
    custom_attrs[:from_prototype_id] = self.plate.single_cell_sorting.sorting_biosample.id
    custom_attrs[:part_of_id] = self.plate.single_cell_sorting.starting_biosample.id
    custom_attrs[:well_id] = self.id
    biosample = self.plate.single_cell_sorting.sorting_biosample.clone_biosample(associated_user_id: self.user.id, custom_attrs: custom_attrs)
    #I first tried using create_biosample!, which did raise ActiveRecord:RecordInvalid. However,
    # while that does issue a Rollback as expected as any exception would in a callback, the form errors appear to be gone
    # and don't display on the form. Thus, the user is left with a re-rendered and populated form w/o any indication
    # of what happened.
    if not biosample.valid?
      raise "Unable to create biosample for well #{self.name}: #{biosample.errors.full_messages}"
      #throws a RuntimeError that I catch in single_cell_sortings_controller.rb in the update() method.
    end
  end

  def set_name
    self.name = get_name
  end

end
