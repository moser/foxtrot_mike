require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/shared_examples_for_accounting_entries')

describe WireLaunch do
  it_behaves_like "an accounting entry factory"
  it { should belong_to :wire_launcher }
  it { should have_many :accounting_entries }
  it { should have_one :abstract_flight }
  it { should have_one :manual_cost }  
end
