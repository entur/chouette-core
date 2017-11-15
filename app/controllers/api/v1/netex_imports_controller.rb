module Api
  module V1
    class NetexImportsController < ChouetteController
      include ControlFlow

      skip_before_action :authenticate

      def create
        respond_to do | format |
          format.json(&method(:create_models))
        end
      end


      private

      def find_workbench
        @workbench = Workbench.find(netex_import_params['workbench_id'])
      rescue ActiveRecord::RecordNotFound
        render json: {errors: {'workbench_id' => 'missing'}}, status: 406
        finish_action!
      end

      def create_models
        find_workbench
        create_referential
        create_netex_import
      end

      def create_netex_import
        attributes = netex_import_params.merge creator: "Webservice"

        attributes = attributes.merge referential_id: @new_referential.id

        @netex_import = NetexImport.new attributes
        @netex_import.save!

        unless @netex_import.referential
          Rails.logger.info "Can't create referential for import #{@netex_import.id}: #{@new_referential.inspect} #{@new_referential.metadatas.inspect} #{@new_referential.errors.full_messages}"
          @netex_import.messages.create criticity: :error, message_key: "referential_creation"
        end
      rescue ActiveRecord::RecordInvalid
        render json: {errors: @netex_import.errors}, status: 406
        finish_action!
      end

      def create_referential
        @new_referential =
          Referential.new(
            name: netex_import_params['name'],
            organisation_id: @workbench.organisation_id,
            workbench_id: @workbench.id,
            metadatas: [metadata]
          )
        @new_referential.save
      end

      def metadata
        metadata = ReferentialMetadata.new

        if netex_import_params['file']
          netex_file = STIF::NetexFile.new(netex_import_params['file'].to_io)
          frame = netex_file.frames.first

          if frame
            metadata.periodes = frame.periods

            line_objectids = frame.line_refs.map { |ref| "STIF:CODIFLIGNE:Line:#{ref}" }
            metadata.line_ids = @workbench.lines.where(objectid: line_objectids).pluck(:id)
          end
        end

        metadata
      end

      def netex_import_params
        params
          .require('netex_import')
          .permit(:file, :name, :workbench_id, :parent_id, :parent_type)
      end
    end
  end
end
