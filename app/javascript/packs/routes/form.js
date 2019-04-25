import '../../helpers/polyfills'

import React from 'react'
import PropTypes from 'prop-types'

import { render } from 'react-dom'
import { Provider } from 'react-redux'
import { createStore } from 'redux'

import reducers from '../../routes/reducers'
import App from '../../routes/containers/App'

// logger, DO NOT REMOVE
import { applyMiddleware } from 'redux'
import { createLogger } from 'redux-logger'
import ReduxThunk from 'redux-thunk'
import promise from 'redux-promise'
  
let store = null

if(Object.assign){
  const loggerMiddleware = createLogger()
  store = createStore(
   reducers,
   {},
   applyMiddleware(ReduxThunk, promise, loggerMiddleware)
 )
}
else{
  // IE
  store = createStore(
   reducers,
   {},
   applyMiddleware(ReduxThunk, promise)
 )
}


render(
  <Provider store={store}>
    <App />
  </Provider>,
  document.getElementById('route')
)
