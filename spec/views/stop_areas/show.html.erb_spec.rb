require 'spec_helper'

describe "/stop_areas/show", :type => :view do

  let!(:stop_area_referential) { assign :stop_area_referential, stop_area.stop_area_referential }
  let!(:stop_area) { assign :stop_area, create(:stop_area) }
  let!(:access_points) { assign :access_points, [] }
  let!(:map) { assign(:map, double(:to_html => '<div id="map"/>'.html_safe)) }

  it "should render h1 with the stop_area name" do
    render
    expect(rendered).to have_selector("h1", :text => Regexp.new(stop_area.name))
  end

  # it "should display a map with class 'stop_area'" do
  #   render
  #   expect(rendered).to have_selector("#map", :class => 'stop_area')
  # end

  it "should render a link to edit the stop_area" do
    render
    expect(rendered).to have_selector("a[href='#{view.edit_stop_area_referential_stop_area_path(stop_area_referential, stop_area)}']")
  end

  it "should render a link to remove the stop_area" do
    render
    expect(rendered).to have_selector("a[href='#{view.stop_area_referential_stop_area_path(stop_area_referential, stop_area)}']")
  end

end
