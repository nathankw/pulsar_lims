require 'rails_helper'

RSpec.describe "biosample_replicates/edit", type: :view do
  before(:each) do
    @biosample_replicate = assign(:biosample_replicate, BiosampleReplicate.create!(
      :user => nil,
      :name => "MyString",
      :upstream_identifier => "MyString",
      :biological_replicate_number => 1,
      :technical_replicate_number => 1,
      :notes => "MyText"
    ))
  end

  it "renders the edit biosample_replicate form" do
    render

    assert_select "form[action=?][method=?]", biosample_replicate_path(@biosample_replicate), "post" do

      assert_select "input#biosample_replicate_user_id[name=?]", "biosample_replicate[user_id]"

      assert_select "input#biosample_replicate_name[name=?]", "biosample_replicate[name]"

      assert_select "input#biosample_replicate_upstream_identifier[name=?]", "biosample_replicate[upstream_identifier]"

      assert_select "input#biosample_replicate_biological_replicate_number[name=?]", "biosample_replicate[biological_replicate_number]"

      assert_select "input#biosample_replicate_technical_replicate_number[name=?]", "biosample_replicate[technical_replicate_number]"

      assert_select "textarea#biosample_replicate_notes[name=?]", "biosample_replicate[notes]"
    end
  end
end
