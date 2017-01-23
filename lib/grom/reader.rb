require 'pry'

module Grom
  class Reader
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def create_hashes
      # Reset all our hashes just in case
      @statements_by_subject  = {}
      @subjects_by_type       = {}
      @connections_by_subject = {}

      RDF::NTriples::Reader.new(@data) do |reader|
        reader.each_statement do |statement|
          subject = statement.subject.to_s

          # TODO: Use Ruby key value syntax in below method.
          Grom::Helper.lazy_array_insert(@statements_by_subject, subject, statement)

          predicate = statement.predicate.to_s

          if predicate == RDF.type.to_s
            Grom::Helper.lazy_array_insert(@subjects_by_type, Grom::Reader.get_id(statement.object), subject)
          end

          if (statement.object =~ URI::regexp) == 0 && predicate != RDF.type.to_s
            Grom::Helper.lazy_array_insert(@connections_by_subject, subject, statement.object.to_s)
          end
        end
      end

      self
    end

    def self.get_id(uri)
      return nil if uri.to_s['/'].nil?

      uri == RDF.type.to_s ? 'type' : uri.to_s.split('/').last
    end
  end
end