import omit from 'lodash/omit'
import { isActionCreate } from './status'
import { getVisibleStopPoints } from './stopPoints'

// Constants
const UPDATE_ROUTE_FORM_INPUT = 'UPDATE_ROUTE_FORM_INPUT'
export const FETCH_ROUTE_START = 'FETCH_ROUTE_START'
export const FETCH_ROUTE_SUCCESS = 'FETCH_ROUTE_SUCCESS'
export const FETCH_ROUTE_ERROR = 'FETCH_ROUTE_ERROR'
export const SUBMIT_ROUTE_START = 'SUBMIT_ROUTE_START'
export const SUBMIT_ROUTE_SUCCESS = 'SUBMIT_ROUTE_SUCCESS'
export const SUBMIT_ROUTE_ERROR = 'SUBMIT_ROUTE_ERROR'

const route = (state = {}, action) => {
  switch(action.type) {
    case UPDATE_ROUTE_FORM_INPUT:
      return Object.assign({}, state, action.attributes)
    case FETCH_ROUTE_SUCCESS:
      return omit(action.json, ['stop_points'])
    default:
    return state
  }
}

export const handleInputChange = attribute => value => (handler = defaultHandler) =>
  handler({ [attribute]: value })

const defaultHandler = attributes => attributes

export const directionHandler = attributes => {
  const wayback = { wayback: attributes.direction === 'straight_forward' ? 'outbound' : 'inbound' }
  return Object.assign(attributes, wayback)
}

export const getDirection = (e) => {
  const el = e.target.nextSibling
  return el.textContent === el.dataset.checkedvalue ? 'straight_forward' : 'backward'
}

export default route

export const getStopPointsAttributes = state => {
  const collection = isActionCreate(state.status) ? getVisibleStopPoints(state.stopPoints) : state.stopPoints
  return collection.map((sp, index) => {
    return {
      id: sp.stoppoint_id || '',
      stop_area_id: sp.stoparea_id,
      position: index,
      for_boarding: sp.for_boarding,
      for_alighting: sp.for_alighting,
      _destroy: sp._destroy
    }
  })
}