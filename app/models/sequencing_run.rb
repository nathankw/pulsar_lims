class SequencingRun< ActiveRecord::Base
  belongs_to :user
  belongs_to :sequencing_request
	belongs_to :report, class_name: "Document"
	has_many   :sequencing_results, dependent: :destroy

	validates :name, length: { minimum: 2, maximum: 40 }, uniqueness: true
	validates :run_name, presence: true

	scope :persisted, lambda { where.not(id: nil) }

	def self.policy_class
		ApplicationPolicy
	end

	def get_barcodes_on_request(without_sequencing_result=False)
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

	def library_sequencing_result_present(lib)
		return sequencing_results.where({library_id: lib.id}).present?
	end

	def get_libraries_without_sequencing_results
		res = []
		sequencing_request.libraries.each do |lib|
			if not library_sequencing_result_present(lib)
				res << lib
			end
		end
		return res
	end
end