import omit from 'lodash/omit'
import { isActionCreate } from './status'

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

export const handleInputChange = attribute => value => () => ({
  [attribute]: value
})
  

export const getDirection = e => e.target.checked ? 'outbound' : 'inbound'

export const getStopPointsAttributes = state => {
  const stopPoints = state.stopPoints.map((sp, index) => {
    return {
      id: sp.stoppoint_id || '',
      stop_area_id: sp.stoparea_id,
      position: index,
      for_boarding: sp.for_boarding,
      for_alighting: sp.for_alighting,
      _destroy: sp._destroy
    }
  })

  return stopPoints.concat(state.deletedStopPoints)
}

export default route