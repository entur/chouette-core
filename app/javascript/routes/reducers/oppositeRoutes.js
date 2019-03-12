// Constants
export const FETCH_OPPOSITE_ROUTES_START = 'FETCH_OPPOSITE_ROUTES_START'
export const FETCH_OPPOSITE_ROUTES_SUCCESS = 'FETCH_OPPOSITE_ROUTES_SUCCESS'
export const FETCH_OPPOSITE_ROUTES_ERROR = 'FETCH_OPPOSITE_ROUTES_ERROR'

const oppositeRoutes = (state = {}, action) => {
  switch(action.type) {
    case FETCH_OPPOSITE_ROUTES_SUCCESS:
      return action.json
    default:
      return state
  }
}

export default oppositeRoutes