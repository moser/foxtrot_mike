require 'roo'

class SpreadSheetNormalizer
  attr_reader :file

  class RooHandler
    def initialize(roo)
      @roo = roo
    end

    def to_hashes
      ((@roo.first_row + 1)..(@roo.last_row)).to_a.map do |n|
        a = @roo.row(@roo.first_row).map { |str| [str] }
        @roo.row(n).each_index do |i|
          a[i] << @roo.row(n)[i]
        end
        Hash[a].with_indifferent_access
      end
    end
  end

  class CSVHandler
    def initialize(file)
      @filename = file
    end

    def to_hashes
      hashes = []
      CSV.read(@filename, headers: true).each do |row|
        hashes << row.to_hash.with_indifferent_access
      end
      hashes
    end
  end

  def initialize(filename)
    @file = filename
  end

  def to_hashes
    handler.to_hashes
  end

  def self.filename_to_handler(filename)
    extension = /\.([^.]+)$/.match(filename)[1]
    case extension
    when 'ods'
      return RooHandler.new(Roo::Openoffice.new(filename))
    when 'xls'
      return RooHandler.new(Roo::Excel.new(filename))
    when 'xlsx'
      return RooHandler.new(Roo::Excelx.new(filename))
    when 'csv'
      return CSVHandler.new(filename)
    end
  end

private
  def handler
    @handler ||= filename_to_handler(@file)
  end
end
