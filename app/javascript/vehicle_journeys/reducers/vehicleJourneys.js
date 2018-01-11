import _ from 'lodash'
import actions from '../actions'

const vehicleJourney= (state = {}, action, keep) => {
  switch (action.type) {
    case 'SELECT_VEHICLEJOURNEY':
      return _.assign({}, state, {selected: !state.selected})
    case 'CANCEL_SELECTION':
      return _.assign({}, state, {selected: false})
    case 'ADD_VEHICLEJOURNEY':
      let pristineVjasList = []
      let prevSp = action.stopPointsList[0]
      let current_time = {
        hour: 0,
        minute: 0
      }
      if(action.data["start_time.hour"] && action.data["start_time.minute"] && action.selectedJourneyPattern.full_schedule){
        current_time.hour = parseInt(action.data["start_time.hour"].value)
        current_time.minute = parseInt(action.data["start_time.minute"].value)
      }
      _.each(action.stopPointsList, (sp) =>{
        if(action.selectedJourneyPattern.full_schedule && action.selectedJourneyPattern.costs && action.selectedJourneyPattern.costs[prevSp.stop_area_id + "-" + sp.stop_area_id]){
          let delta = parseInt(action.selectedJourneyPattern.costs[prevSp.stop_area_id + "-" + sp.stop_area_id].time)
          let delta_hour = parseInt(delta/60)
          let delta_minute = delta - 60*delta_hour
          current_time.hour += delta_hour
          current_time.minute += delta_minute
          let extra_hours = parseInt(current_time.minute/60)
          current_time.hour += extra_hours
          current_time.minute -= extra_hours*60
          current_time.hour = current_time.hour % 24
          prevSp = sp
        }
        let offsetHours = sp.time_zone_offset / 3600
        let offsetminutes = sp.time_zone_offset/60 - 60*offsetHours
        let newVjas = {
          delta: 0,
          departure_time:{
            hour: (24 + current_time.hour + offsetHours) % 24,
            minute: current_time.minute + offsetminutes
          },
          arrival_time:{
            hour: (24 + current_time.hour + offsetHours) % 24,
            minute: current_time.minute + offsetminutes
          },
          stop_point_objectid: sp.object_id,
          stop_area_cityname: sp.city_name,
          dummy: true
        }
        if(current_time.hour + offsetHours > 24){
          newVjas.departure_day_offset = 1
          newVjas.arrival_day_offset = 1
        }
        if(current_time.hour + offsetHours < 0){
          newVjas.departure_day_offset = -1
          newVjas.arrival_day_offset = -1
        }

        _.each(action.selectedJourneyPattern.stop_areas, (jp) =>{
          if (jp.stop_area_short_description.id == sp.id){
            newVjas.dummy = false
            return
          }
        })

        if(newVjas.dummy){
          newVjas.departure_time = {hour: "00", minute: "00"}
          newVjas.arrival_time = {hour: "00", minute: "00"}
        }
        pristineVjasList.push(newVjas)

      })

      return {
        company: action.selectedCompany,
        journey_pattern: action.selectedJourneyPattern,
        published_journey_name: action.data.published_journey_name.value,
        published_journey_identifier: action.data.published_journey_identifier.value,
        objectid: '',
        short_id: '',
        footnotes: [],
        time_tables: [],
        purchase_windows: [],
        vehicle_journey_at_stops: pristineVjasList,
        selected: false,
        deletable: false,
        transport_mode: window.transportMode ? window.transportMode : 'undefined',
        transport_submode: window.transportSubmode ? window.transportSubmode : 'undefined',
        custom_fields: action.data.custom_fields
      }
    case 'DUPLICATE_VEHICLEJOURNEY':
    case 'SHIFT_VEHICLEJOURNEY':
      let shiftedArray, shiftedSchedule, shiftedVjas
      shiftedArray = state.vehicle_journey_at_stops.map((vjas, i) => {
        if (!vjas.dummy){
          shiftedSchedule = actions.getShiftedSchedule(vjas, action.addtionalTime)

          shiftedVjas =  _.assign({}, state.vehicle_journey_at_stops[i], shiftedSchedule)
          vjas = _.assign({}, state.vehicle_journey_at_stops[i], shiftedVjas)
          if(!keep){
            delete vjas['id']
          }
          return vjas
        }else {
          if(!keep){
            delete vjas['id']
          }
          return vjas
        }
      })
      return _.assign({}, state, {vehicle_journey_at_stops: shiftedArray})
    case 'UPDATE_TIME':
      let vj, vjas, vjasArray, newSchedule
      vjasArray = state.vehicle_journey_at_stops.map((vjas, i) =>{
        if(i == action.subIndex){
          newSchedule = {
            departure_time: _.assign({}, vjas.departure_time),
            arrival_time: _.assign({}, vjas.arrival_time)
          }
          if (action.isDeparture){
            newSchedule.departure_time[action.timeUnit] = actions.pad(action.val, action.timeUnit)
            if(!action.isArrivalsToggled)
              newSchedule.arrival_time[action.timeUnit] = newSchedule.departure_time[action.timeUnit]
            newSchedule = actions.adjustSchedule(action, newSchedule)
            return _.assign({}, state.vehicle_journey_at_stops[action.subIndex], {arrival_time: newSchedule.arrival_time, departure_time: newSchedule.departure_time, delta: newSchedule.delta})
          }else{
            newSchedule.arrival_time[action.timeUnit] = actions.pad(action.val, action.timeUnit)
            newSchedule = actions.adjustSchedule(action, newSchedule)
            return _.assign({}, state.vehicle_journey_at_stops[action.subIndex],  {arrival_time: newSchedule.arrival_time, departure_time: newSchedule.departure_time, delta: newSchedule.delta})
          }
        }else{
          return vjas
        }
      })
      return _.assign({}, state, {vehicle_journey_at_stops: vjasArray})
    default:
      return state
  }
}

export default function vehicleJourneys(state = [], action) {
  switch (action.type) {
    case 'RECEIVE_VEHICLE_JOURNEYS':
      return [...action.json]
    case 'RECEIVE_ERRORS':
      return [...action.json]
    case 'GO_TO_PREVIOUS_PAGE':
      if(action.pagination.page > 1){
        actions.fetchVehicleJourneys(action.dispatch, action.pagination.page, action.nextPage, action.queryString)
      }
      return state
    case 'GO_TO_NEXT_PAGE':
      if (action.pagination.totalCount - (action.pagination.page * action.pagination.perPage) > 0){
        actions.fetchVehicleJourneys(action.dispatch, action.pagination.page, action.nextPage, action.queryString)
      }
      return state
    case 'ADD_VEHICLEJOURNEY':
      return [
        vehicleJourney(state, action),
        ...state
      ]
    case 'EDIT_VEHICLEJOURNEY':
      return state.map((vj, i) => {
        if (vj.selected){
          return _.assign({}, vj, {
            company: action.selectedCompany,
            published_journey_name: action.data.published_journey_name.value,
            published_journey_identifier: action.data.published_journey_identifier.value,
            custom_fields: action.data.custom_fields,
          })
        }else{
          return vj
        }
      })
    case 'EDIT_VEHICLEJOURNEY_NOTES':
      return state.map((vj, i) => {
        if (vj.selected){
          return _.assign({}, vj, {
            footnotes: action.footnotes
          })
        }else{
          return vj
        }
      })
    case 'EDIT_VEHICLEJOURNEYS_TIMETABLES':
      let newTimetables = JSON.parse(JSON.stringify(action.timetables))
      return state.map((vj,i) =>{
        if(vj.selected){
          let updatedVJ = _.assign({}, vj)
          action.vehicleJourneys.map((vjm, j) =>{
            if(vj.objectid == vjm.objectid){
              updatedVJ.time_tables =  newTimetables
            }
          })
          return updatedVJ
        }else{
          return vj
        }
      })
      case 'EDIT_VEHICLEJOURNEYS_PURCHASE_WINDOWS':
        let newWindows = JSON.parse(JSON.stringify(action.purchase_windows))
        return state.map((vj,i) =>{
          if(vj.selected){
            let updatedVJ = _.assign({}, vj)
            action.vehicleJourneys.map((vjm, j) =>{
              if(vj.objectid == vjm.objectid){
                updatedVJ.purchase_windows = newWindows
              }
            })
            return updatedVJ
          }else{
            return vj
          }
        })
    case 'SHIFT_VEHICLEJOURNEY':
      return state.map((vj, i) => {
        if (vj.selected){
          return vehicleJourney(vj, action, true)
        }else{
          return vj
        }
      })
    case 'DUPLICATE_VEHICLEJOURNEY':
      let dupeVj
      let dupes = []
      let selectedIndex
      let val = action.addtionalTime
      let departureDelta = action.departureDelta
      state.map((vj, i) => {
        if(vj.selected){
          selectedIndex = i
          for (i = 0; i< action.duplicateNumber; i++){
            // We check if the departureDelta is != 0 to create the first VJ on the updated deparure time if it is the case
            // let delta = departureDelta == 0 ? 1 : 0
            // action.addtionalTime = (val * (i + delta)) + departureDelta
            action.addtionalTime = (val * (i + 1)) + departureDelta
            dupeVj = vehicleJourney(vj, action, false)
            dupeVj.published_journey_name = dupeVj.published_journey_name + '-' + i
            dupeVj.selected = false
            delete dupeVj['objectid']
            dupes.push(dupeVj)
          }
        }
      })
      let concatArray = state.slice(0, selectedIndex + 1).concat(dupes)
      concatArray = concatArray.concat(state.slice(selectedIndex + 1))
      return concatArray
    case 'DELETE_VEHICLEJOURNEYS':
      return state.map((vj, i) =>{
        if (vj.selected){
          return _.assign({}, vj, {deletable: true, selected: false})
        } else {
          return vj
        }
      })
    case 'SELECT_VEHICLEJOURNEY':
      return state.map((vj, i) =>{
        if (i == action.index){
          return vehicleJourney(vj, action)
        } else {
          return vj
        }
      })
    case 'CANCEL_SELECTION':
      return state.map((vj) => {
        return vehicleJourney(vj, action)
      })
    case 'UPDATE_TIME':
      return state.map((vj, i) =>{
        if (i == action.index){
          return vehicleJourney(vj, action)
        } else {
          return vj
        }
      })
    default:
      return state
  }
}
