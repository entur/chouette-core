import { getRedirectUrl } from '../reducers/status'

const actions = {
  addStop : () => {
    return {
      type: 'ADD_STOP'
    }
  },
  moveStopUp : (index) => {
    return {
      type: 'MOVE_STOP_UP',
      index
    }
  },
  moveStopDown : (index) => {
    return {
      type: 'MOVE_STOP_DOWN',
      index
    }
  },
  deleteStop : (index, stopPointId) => {
    return {
      type: 'DELETE_STOP',
      index,
      stopPointId
    }
  },
  updateInputValue : (index, text) => {
    return {
      type : 'UPDATE_INPUT_VALUE',
      index,
      text
    }
  },
  updateSelectValue: (e, index) => {
    return {
      type :'UPDATE_SELECT_VALUE',
      select_id: e.currentTarget.id,
      select_value: e.currentTarget.value,
      index
    }
  },
  toggleMap: (index) =>({
    type: 'TOGGLE_MAP',
    index
  }),
  toggleEdit: (index) =>({
    type: 'TOGGLE_EDIT',
    index
  }),
  closeMaps: () => ({
    type : 'CLOSE_MAP'
  }),
  selectMarker: (index, data) =>({
    type: 'SELECT_MARKER',
    index,
    data
  }),
  unselectMarker: (index) => ({
    type: 'UNSELECT_MARKER',
    index
  }),
  updateRouteFormInput: attributes => ({
    type: 'UPDATE_ROUTE_FORM_INPUT',
    attributes
  }),
  fetchStart: type => ({ type }),
  fetchSuccess: (type, json) => ({ type, json }),
  fetchError: (type, error) => ({ type, error }),
  submitStart: type => ({ type }),
  submitSuccess: (type, json) => ({ type, json }),
  submitError: (type, error) => ({ type, error }),
  fetchWrapper: dispatch => url => async type => {
    const { fetchStart, fetchSuccess, fetchError } = actions
    try {
      dispatch(fetchStart(`FETCH_${type}_START)`))
      const response = await fetch(url)
      const json = await response.json()
      dispatch(fetchSuccess(`FETCH_${type}_SUCCESS`, json))
    } catch(e) {
      dispatch(fetchError(`FETCH_${type}_ERROR`, e))
    }
  },
  fetchUserPermissions: dispatch => {
    actions.fetchWrapper(dispatch)(window.fetchUserPermissionsUrl)('USER_PERMISSIONS')
  },
  fetchOppositeRoutes: dispatch => {
    actions.fetchWrapper(dispatch)(window.fetchOppositeRoutesUrl)('OPPOSITE_ROUTES')
  },
  fetchRoute: dispatch => {
    actions.fetchWrapper(dispatch)(window.fetchRouteUrl)('ROUTE')
  },
  validateField: ({category, ...value}) => ({
    type: 'VALIDATE_FIELD',
    category,
    value
  }),
  submitRoute: dispatch => requestMethod => async route => {
    try {
      dispatch(actions.submitStart('SUBMIT_ROUTE_START')) 
      const response = await fetch(window.routeSubmitUrl, {
        credentials: 'same-origin',
        method: requestMethod,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json;  charset=utf-8',
          'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
          },
        body: JSON.stringify({route: route})
        }
      )
      const json = await response.json()
      dispatch(actions.fetchSuccess('SUBMIT_ROUTE_SUCCESS', json))
      window.location.assign(window.redirectUrl)
    } catch(e) {
      dispatch(actions.fetchError('SUBMIT_ROUTE_ERROR', e))
    }
  }
}

module.exports = actions
