import React, { Component } from 'react'
import VehicleJourneys from '../../../../app/javascript/vehicle_journeys/components/VehicleJourneys'
import renderer from 'react-test-renderer'

import I18n from '../../support/jest-i18n'

describe('stopPointHeader', () => {
  set('features', () => {
    return {}
  })
  set('component', () => {
    let props = {
      status: {},
      filters: {
        permissions: {},
        features: features
      },
      onLoadFirstPage: ()=>{},
      onUpdateTime: ()=>{},
      onSelectVehicleJourney: ()=>{},
      stopPointsList: [stop_point, same_city_stop_point, other_country_stop_point],
			vehicleJourneys: [],
			customFields: {},
			extraHeaders: [],
      selection: {},
      selectionMode: false
    }
    let list = renderer.create(
      <VehicleJourneys
        status={props.status}
        filters={props.filters}
        onLoadFirstPage={props.onLoadFirstPage}
        onUpdateTime={props.onUpdateTime}
        onSelectVehicleJourney={props.onSelectVehicleJourney}
        stopPointsList={props.stopPointsList}
        vehicleJourneys={props.vehicleJourneys}
				customFields={props.customFields}
        extraHeaders={props.extraHeaders}
        selection={props.selection}
        selectionMode={props.selectionMode}
      />
    ).toJSON()

    return list
  })

  set('stop_point', () => {
    return {
      name: "Stop point",
      city_name: "City Name",
      zip_code: "12345",
      country_code: "FR",
      country_name: "france",
      object_id: "sp-FR"
    }
  })

  set('same_city_stop_point', () => {
    return {
      name: "Antother stop point",
      city_name: stop_point.city_name,
      zip_code: stop_point.zip_code,
      country_code: stop_point.country_code,
      country_name: stop_point.country_name,
      object_id: stop_point.object_id + "-2"
    }
  })

  set('other_country_stop_point', () => {
    return {
      name: "Antother stop point",
      city_name: "New York",
      zip_code: "232323",
      country_code: "US",
      country_name: "USA",
      object_id: "sp-USA"
    }
  })
  it('should display the city name', () => {
    expect(component).toMatchSnapshot()
  })
  context('with the "long_distance_routes" feature', () => {
    set('features', () => {
      return { long_distance_routes: true }
    })
    it('should display the country name', () => {
      expect(component).toMatchSnapshot()
    })
  })
})
