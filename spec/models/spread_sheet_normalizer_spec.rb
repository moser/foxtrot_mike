require 'spec_helper'

def test_file(format)
  File.join(Rails.root, "spec/data/foo.#{format}")
end

describe SpreadSheetNormalizer do
  describe ".filename_to_handler" do
    describe "returns a RooHandler for" do
      %w(ods xls xlsx).each do |format|
        it format do
          SpreadSheetNormalizer.filename_to_handler(test_file(format)).class.should == SpreadSheetNormalizer::RooHandler
        end
      end
    end

    it 'returns a CSVHandler for csv' do
      SpreadSheetNormalizer.filename_to_handler(test_file('csv')).class.should == SpreadSheetNormalizer::CSVHandler
    end
  end

  describe "#to_hash" do
    it "delegates to handler" do
      handler = mock(:handler)
      handler.should_receive(:to_hashes)
      normalizer = SpreadSheetNormalizer.new('foo.bar')
      normalizer.stub(:handler).and_return(handler)
      normalizer.to_hashes
    end
  end


  def check_data(hashes)
    hashes.class.should == Array
    hashes.each do |hash|
      hash.class.should == HashWithIndifferentAccess
    end
    ['1', 1.0].should include(hashes[0][:head])
    hashes[1]['stuff'].should == "gargl"
  end

  describe "::CSVHandler" do
    let(:handler) { SpreadSheetNormalizer::CSVHandler.new(test_file('csv')) }

    describe "#to_hash" do
      it "returns an array of hashes containing the data" do
        check_data(handler.to_hashes)
      end
    end
  end

  describe "::RooHandler" do
    %w(ods xls xlsx).each do |format|
      describe "for #{format}" do
        let(:handler) { SpreadSheetNormalizer.filename_to_handler(test_file(format)) }

        describe "#to_hash" do
          it "returns an array of hashes containing the data" do
            check_data(handler.to_hashes)
          end
        end
      end
    end
  end
  
end
