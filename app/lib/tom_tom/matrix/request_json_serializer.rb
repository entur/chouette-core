module TomTom
  class Matrix
    class RequestJSONSerializer
      def self.dump(hash)
        hash[:origins].map! do |point|
          point_to_f(point)
        end
        hash[:destinations].map! do |point|
          point_to_f(point)
        end

        JSON.dump(hash)
      end

      private

      def self.point_to_f(point)
        point[:point][:latitude] = point[:point][:latitude].to_f
        point[:point][:longitude] = point[:point][:longitude].to_f

        point
      end
    end
  end
end
