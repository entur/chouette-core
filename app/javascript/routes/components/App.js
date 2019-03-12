import React, { Component } from 'react'
import PropTypes from 'prop-types'
import RouteForm from '../containers/Route'
import AddStopPoint from '../containers/AddStopPoint'
import VisibleStopPoints from'../containers/VisibleStopPoints'
import SaveRoute from'../containers/SaveRoute'

export default class App extends Component {
  constructor(props) {
    super(props)
  }
  
  componentDidMount() {
    console.log('mounted')
    const { onLoadFirstPage, isActionUpdate } = this.props
    onLoadFirstPage(isActionUpdate)
  }

  render() {
    return (
      <div>
        <RouteForm />
        <div className="separator"></div>
        <VisibleStopPoints />
        <AddStopPoint />
        <SaveRoute />
      </div>
    )
  }
}
