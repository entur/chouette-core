import _ from 'lodash'
import { FETCH_ROUTE_SUCCESS } from './route'

const stopPoint = (state = {}, action, length) => {
  switch (action.type) {
    case 'ADD_STOP':
      return {
        text: '',
        index: length,
        edit: true,
        for_boarding: 'normal',
        for_alighting: 'normal',
        olMap: {
          isOpened: false,
          json: {}
        }
      }
    default:
      return state
  }
}

const stopPoints = (state = [], action) => {
  const stopPoints = getVisibleStopPoints(state)
  switch (action.type) {
    case 'ADD_STOP':
      return [
        ...stopPoints,
        stopPoint(undefined, action, stopPoints.length)
      ]
    case 'MOVE_STOP_UP':
      return [
        ...stopPoints.slice(0, action.index - 1),
        _.assign({}, stopPoints[action.index], { index: action.index - 1 }),
        _.assign({}, stopPoints[action.index - 1], { index: action.index }),
        ...stopPoints.slice(action.index + 1)
      ]
    case 'MOVE_STOP_DOWN':
      return [
        ...stopPoints.slice(0, action.index),
        _.assign({}, stopPoints[action.index + 1], { index: action.index }),
        _.assign({}, stopPoints[action.index], { index: action.index + 1 }),
        ...stopPoints.slice(action.index + 2)
      ]
    case 'DELETE_STOP':
      return stopPoints.map((sp, i) => i === action.index ? Object.assign({}, sp, {_destroy: true}) : sp)
    case 'UPDATE_INPUT_VALUE':
      return stopPoints.map( (t, i) => {
        if (i === action.index) {
          let forAlightingAndBoarding = action.text.stoparea_kind === 'commercial' ? 'normal' : 'forbidden'
          return _.assign(
            {},
            t,
            {
              stoppoint_id: t.stoppoint_id,
              text: action.text.text,
              stoparea_id: action.text.stoparea_id,
              stoparea_kind: action.text.stoparea_kind,
              user_objectid: action.text.user_objectid,
              latitude: action.text.latitude,
              longitude: action.text.longitude,
              name: action.text.name,
              short_name: action.text.short_name,
              area_type: action.text.area_type,
              city_name: action.text.city_name,
              comment: action.text.comment,
              registration_number: action.text.registration_number,
              stop_area_referential_id: action.text.stop_area_referential_id,
              for_alighting: forAlightingAndBoarding,
              for_boarding: forAlightingAndBoarding
            }
          )
        } else {
          return t
        }
      })
    case 'UPDATE_SELECT_VALUE':
      return stopPoints.map( (t, i) => {
        if (i === action.index) {
          let stopState = _.assign({}, t)
          stopState[action.select_id] = action.select_value
          return stopState
        } else {
          return t
        }
      })
    case 'TOGGLE_EDIT':
      return stopPoints.map((t, i) => {
        if (i === action.index){
          return _.assign({}, t, {edit: !t.edit})
        } else {
          return t
        }
      })
    case 'TOGGLE_MAP':
      return stopPoints.map( (t, i) => {
        if (i === action.index){
          let val = !t.olMap.isOpened
          let jsonData = val ? _.assign({}, t, {olMap: undefined}) : {}
          let stateMap = _.assign({}, t.olMap, {isOpened: val, json: jsonData})
          return _.assign({}, t, {olMap: stateMap})
        }else {
          let emptyMap = _.assign({}, t.olMap, {isOpened: false, json : {}})
          return _.assign({}, t, {olMap: emptyMap})
        }
      })
    case 'SELECT_MARKER':
      return stopPoints.map((t, i) => {
        if (i === action.index){
          let stateMap = _.assign({}, t.olMap, {json: action.data})
          return _.assign({}, t, {olMap: stateMap})
        } else {
          return t
        }
      })
    case 'UNSELECT_MARKER':
      return stopPoints.map((t, i) => {
        if (i === action.index){
          let stateMap = _.assign({}, t.olMap, {json: {}})
          return _.assign({}, t, {olMap: stateMap})
        } else {
          return t
        }
      })
    case 'CLOSE_MAP':
      return state.map( (t, i) => {
        let emptyMap = _.assign({}, t.olMap, {isOpened: false, json: {}})
        return _.assign({}, t, {olMap: emptyMap})
      })
    case FETCH_ROUTE_SUCCESS:
      return action.json['stop_points']
    default:
      return stopPoints
  }
}

export default stopPoints

export const getVisibleStopPoints = stopPointsState => stopPointsState.filter(sp => !sp._destroy)