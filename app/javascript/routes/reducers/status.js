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
      return Object.assign({}, state, fetchStart)
    case FETCH_USER_PERMISSIONS_SUCCESS:
      return Object.assign({}, state, {policy: action.json}, fetchSuccess)
    case FETCH_OPPOSITE_ROUTES_SUCCESS:
    case FETCH_ROUTE_SUCCESS:
      return Object.assign({}, state, fetchSuccess)
    case FETCH_USER_PERMISSIONS_ERROR:
    case FETCH_OPPOSITE_ROUTES_ERROR:
    case FETCH_ROUTE_ERROR:
      return Object.assign({}, state, fetchError)
    default:
      return state
  }
}

const fetchStart = { isFetching: true, fetchSuccess: false, fetchError: false }
const fetchSuccess = { isFetching: false, fetchSuccess: true, fetchError: false }
const fetchError = { isFetching: false, fetchSuccess: false, fetchError: true }

export const isActionCreate = statusState => statusState.action === 'create'
export const getRequestMethod = statusState => isActionCreate(statusState) ? 'POST' : 'PATCH'

export default status