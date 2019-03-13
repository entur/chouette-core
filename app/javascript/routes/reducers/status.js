import { FETCH_OPPOSITE_ROUTES_START, FETCH_OPPOSITE_ROUTES_SUCCESS, FETCH_OPPOSITE_ROUTES_ERROR } from './oppositeRoutes'
import { FETCH_ROUTE_START, FETCH_ROUTE_SUCCESS, FETCH_ROUTE_ERROR } from './oppositeRoutes'

// Constants
export const FETCH_USER_PERMISSIONS_START = 'FETCH_USER_PERMISSIONS_START'
export const FETCH_USER_PERMISSIONS_SUCCESS = 'FETCH_USER_PERMISSIONS_SUCCESS'
export const FETCH_USER_PERMISSIONS_ERROR = 'FETCH_USER_PERMISSIONS_ERROR'

// Reducer
const status = (state = {}, action) => {
  switch (action.type) {
    case FETCH_USER_PERMISSIONS_START:
    case FETCH_OPPOSITE_ROUTES_START:
    case FETCH_ROUTE_START:
      return Object.assign({}, state, { isFetching: true, fetchSuccess: false, fetchError: false })
    case FETCH_USER_PERMISSIONS_SUCCESS:
      return Object.assign({}, state, {policy: action.json}, { isFetching: false, fetchSuccess: true, fetchError: false })
    case FETCH_OPPOSITE_ROUTES_SUCCESS:
    case FETCH_ROUTE_SUCCESS:
      return Object.assign({}, state, { isFetching: false, fetchSuccess: true, fetchError: false })
    case FETCH_USER_PERMISSIONS_ERROR:
    case FETCH_OPPOSITE_ROUTES_ERROR:
    case FETCH_ROUTE_ERROR:
      return Object.assign({}, state, { isFetching: false, fetchSuccess: false, fetchError: true })
    default:
      return state
  }
}

export const isActionCreate = statusState => statusState.action === 'create'
export const getRequestMethod = statusState => isActionCreate(statusState) ? 'POST' : 'PATCH'

export default status