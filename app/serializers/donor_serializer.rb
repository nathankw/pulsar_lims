class DonorSerializer < ActiveModel::Serializer
  embed :ids
  self.root = false

  attributes :id, :age, :gender, :name, :notes, :upstream_identifier, :created_at, :updated_at

  has_one :user
end
