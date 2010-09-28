require 'spec_helper'

describe License do
  it { should belong_to :person }
  it { should have_and_belong_to_many :legal_plane_classes }
end
