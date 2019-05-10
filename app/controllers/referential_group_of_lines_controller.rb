class ReferentialGroupOfLinesController < ChouetteController
  include ReferentialSupport
  defaults :resource_class => Chouette::GroupOfLine, :collection_name => 'group_of_lines', :instance_name => 'group_of_line'

  respond_to :html
  respond_to :xml
  respond_to :json
  respond_to :kml, :only => :show
  respond_to :js, :only => :index

  belongs_to :referential

  def show
    @lines = resource.lines.order(:name)
    show!
  end

  def index
    index! do |format|
      format.html {
        if collection.out_of_bounds?
          redirect_to params.merge(:page => 1)
        end
      }
    end
  end


  def name_filter
    respond_to do |format|
      format.json { render :json => filtered_group_of_lines_maps}
    end
  end


  protected

  def build_resource
    super.tap do |resource|
      resource.line_referential = referential.line_referential
    end
  end

  def filtered_group_of_lines_maps
    filtered_group_of_lines.collect do |group_of_line|
      { :id => group_of_line.id, :name => group_of_line.name }
    end
  end

  def filtered_group_of_lines
    referential.group_of_lines.select{ |t| t.name =~ /#{params[:q]}/i  }
  end

  def collection
    @q = referential.workbench.group_of_lines.ransack(params[:q])
    @group_of_lines ||= @q.result(:distinct => true).order(:name).paginate(:page => params[:page])
  end

  def resource_url(group_of_line = nil)
    referential_group_of_line_path(referential, group_of_line || resource)
  end

  def collection_url
    referential_group_of_lines_path(referential)
  end


  private

  def group_of_line_params
    params.require(:group_of_line).permit( :objectid, :object_version, :name, :comment, :lines, :registration_number, :line_tokens)
  end

end
