require 'csv'
require 'time'
require 'bigdecimal'
class StreamCSVParser
  def initialize(file_path, casters = {})
    @file_path = file_path
    @casters = {
      int: ->(v) { v.to_i },
      decimal: ->(v) { BigDecimal(v) },
      time: ->(v) { Time.parse(v) }
    }.merge(casters)
  end
  def parse
    CSV.foreach(@file_path, headers: true) do |row|
      yield cast_row(row.to_h)
    end
  end
  private
  def cast_row(row)
    row.transform_values do |v|
      if integer?(v)
        @casters[:int].call(v)
      elsif decimal?(v)
        @casters[:decimal].call(v)
      elsif time?(v)
        @casters[:time].call(v)
      else
        v
      end
    end
  end
  def integer?(v)
    v =~ /\A-?\d+\z/
  end
  def decimal?(v)
    v =~ /\A-?\d+\.\d+\z/
  end
  def time?(v)
    v =~ /\A\d{4}-\d{2}-\d{2}/
  end
end
parser = StreamCSVParser.new("data.csv")
parser.parse do |row|
  p row
end
