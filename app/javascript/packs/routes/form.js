import '../../helpers/polyfills'

import React from 'react'
import PropTypes from 'prop-types'

import { render } from 'react-dom'
import { Provider } from 'react-redux'
import { createStore } from 'redux'

import reducers from '../../routes/reducers'
import App from '../../routes/containers/App'

// logger, DO NOT REMOVE
var applyMiddleware = require('redux').applyMiddleware
import {createLogger} from 'redux-logger';
var thunkMiddleware = require('redux-thunk').default
var promise = require('redux-promise')

const initialState = {
  route: {
    name: '',
    published_name: '',
    direction: 'straight_forward',
    wayback: 'outbound',
    opposite_route_id: null,
    line_id: parseInt(window.location.pathname.split('/')[4])
  },
  stopPoints: [],
  status: {
    action: window.routeFormAction,
    editMode: true,
    policy: {},
    isFetching: false,
    fetchSuccess: false,
    fetchError: false,
    isSubmitting: false,
    submitSuccess: false,
    submitError: false
  },
  oppositeRoutes: {}
}
  
let store = null

if(Object.assign){
  const loggerMiddleware = createLogger()
  store = createStore(
   reducers,
   initialState,
   applyMiddleware(thunkMiddleware, promise, loggerMiddleware)
 )
}
else{
  // IE
  store = createStore(
   reducers,
   initialState,
   applyMiddleware(thunkMiddleware, promise)
 )
}


render(
  <Provider store={store}>
    <App />
  </Provider>,
  document.getElementById('route')
)
