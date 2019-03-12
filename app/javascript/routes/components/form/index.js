import React, { Component } from 'react'
import PropTypes from 'prop-types'
import TextInput from './TextInput'
import SwitchInput from './SwitchInput'
import SelectInput from './SelectInput'

export default class RouteForm extends Component {
  constructor(props) {
    super(props)
  }
  
  render() {
    const {
      route,
      errors,
      onUpdateName,
      onUpdatePublishedName,
      onUpdateDirection,
      onUpdateOppositeRoute,
      oppositeRoutesForDirection
    } = this.props
    return (
      <div>
        <form className='form-horizontal'>
          <div className='row'>
            <div className='col-lg-12'>
              <TextInput
                inputId='route_name'
                inputName='route[name]'
                labelText='Nom'
                required
                value={route.name}
                onChange={onUpdateName}
                hasError={errors.name}
              />
              <TextInput
                inputId='route_published_name'
                inputName='route[published_name]'
                labelText='Nom public'
                required
                value={route.published_name}
                onChange={onUpdatePublishedName}
                hasError={errors.published_name}
              />
              <SwitchInput
                inputId='route_wayback'
                name='route[wayback]'
                labelText='Sens'
                value={route.direction}
                onChange={onUpdateDirection}
              />
              <SelectInput
                inputId='route_opposite_route_id'
                inputName='route[opposite_route_id]'
                labelText='Itinéraire associcé'
                value={route.opposite_route_id}
                onChange={onUpdateOppositeRoute}
                options={oppositeRoutesForDirection}
              />
            </div>
          </div>
        </form>
      </div>
    )
  }
}