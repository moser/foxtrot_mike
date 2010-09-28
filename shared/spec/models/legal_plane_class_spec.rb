require 'spec_helper'

describe LegalPlaneClass do
  it { should have_and_belong_to_many :licenses }
end
