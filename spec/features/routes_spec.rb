# -*- coding: utf-8 -*-
require 'spec_helper'

describe "Routes", :type => :feature do
  login_user

  let!(:line) { create(:line) }
  let!(:route) { create(:route, :line => line) }
  let!(:route2) { create(:route, :line => line) }
  #let!(:stop_areas) { Array.new(4) { create(:stop_area) } }
  let!(:stop_points) { Array.new(4) { create(:stop_point, :route => route) } }
  let!(:journey_pattern) { create(:journey_pattern, route: route) }

  describe "from lines page to a line page" do
    it "display line's routes" do
      visit referential_lines_path(referential)
      first(:link, 'Voir').click
      expect(page).to have_content(route.name)
      expect(page).to have_content(route2.name)
    end
  end

  describe "from line's page to route's page" do
    it "display route properties" do
      visit referential_line_path(referential,line)
      click_link "#{route.name}"
      expect(page).to have_content(route.name)
      expect(page).to have_content(route.number)
    end
  end

  describe "from line's page, create a new route" do
    it "return to line's page that display new route" do
      visit referential_line_path(referential,line)
      click_link "Ajouter un itinéraire"
      fill_in "route_name", :with => "A to B"
      # select 'Aller', :from => "route_direction"
      select 'Aller', :from => "route_wayback"
      click_button("Créer un itinéraire")
      expect(page).to have_content("A to B")
    end
  end

  describe "Modifies boarding/alighting properties on route stops" do
    xit "Puts (http) an update request" do
      #visit edit_boarding_alighting_referential_line_route_path(referential, line, route)
      visit referential_line_route_path(referential, line, route)
      click_link I18n.t('routes.actions.edit_boarding_alighting')
      #select('', :from => '')
      # Changes the boarding of the first stop
      # Changes the alighting of the last stop
      # save
      #click_button(I18n.t('helpers.submit.update', model: I18n.t('activerecord.models.route.one')))
      click_button(I18n.t('helpers.submit.update', model: I18n.t('activerecord.models.route.one')))
    end
  end

  describe 'show' do
    before(:each) { visit referential_line_route_path(referential, line, route) }

    context 'user has permission to edit journey patterns' do
      it 'shows edit links for journey patterns' do
        expect(page).to have_content(I18n.t('actions.edit'))
      end
    end

    context 'user does not have permission to edit journey patterns' do
      it 'does not show edit links for journey patterns' do
        @user.update_attribute(:permissions, [])
        visit referential_line_route_path(referential, line, route)
        expect(page).not_to have_link(I18n.t('actions.edit'), href: edit_referential_line_route_journey_pattern_path(referential, line, route, journey_pattern))
      end
    end

    context 'user has permission to destroy journey patterns' do
      it 'shows destroy links for journey patterns' do
        expect(page).to have_content(I18n.t('actions.destroy'))
      end
    end

    context 'user does not have permission to destroy journey patterns' do
      it 'does not show destroy links for journey patterns' do
        @user.update_attribute(:permissions, [])
        visit referential_line_route_path(referential, line, route)
        expect(page).not_to have_link(I18n.t('actions.destroy'), href: referential_line_route_journey_pattern_path(referential, line, route, journey_pattern))
      end
    end
  end

  describe 'referential line show' do
    before(:each) { visit referential_line_path(referential, line) }

    context 'user has permission to edit routes' do
      it 'shows edit buttons for routes' do
        expect(page).to have_css('span.fa.fa-pencil')
      end
    end

    context 'user does not have permission to edit routes' do
      it 'does not show edit buttons for routes' do
        @user.update_attribute(:permissions, [])
        visit referential_line_path(referential, line)
        expect(page).not_to have_css('span.fa.fa-pencil')
      end
    end

    context 'user has permission to create routes' do
      it 'shows link to a create route page' do
        expect(page).to have_content(I18n.t('routes.actions.new'))
      end
    end

    context 'user does not have permission to create routes' do
      it 'does not show link to a create route page' do
        @user.update_attribute(:permissions, [])
        visit referential_line_path(referential, line)
        expect(page).not_to have_content(I18n.t('routes.actions.new'))
      end
    end

    context 'user has permission to destroy routes' do
      it 'shows destroy buttons for routes' do
        expect(page).to have_css('span.fa.fa-trash-o')
      end
    end

    context 'user does not have permission to destroy routes' do
      it 'does not show destroy buttons for routes' do
        @user.update_attribute(:permissions, [])
        visit referential_line_path(referential, line)
        expect(page).not_to have_css('span.fa.fa-trash-o')
      end
    end
  end
end
