import { combineReducers } from 'redux'
import formErrors from './formErrors'
import oppositeRoutes from './oppositeRoutes'
import route from './route'
import status from './status'
import stopPoints from './stopPoints'

const routesApp = combineReducers({
  route,
  oppositeRoutes,
  stopPoints,
  status,
  formErrors
})

export default routesApp
