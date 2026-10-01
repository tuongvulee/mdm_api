class ApplicationSerializer
    def self.collection(records)
        records.map { |record| new(record).as_json }
    end

    def initialize(record)
        @record = record
    end

    private

    attr_reader :record
end
