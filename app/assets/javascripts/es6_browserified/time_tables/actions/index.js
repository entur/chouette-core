const _ = require('lodash')

const actions = {
  strToArrayDayTypes: (str) =>{
    let weekDays = ['Di', 'Lu', 'Ma', 'Me', 'Je', 'Ve', 'Sa']
    return weekDays.map((day, i) => str.indexOf(day) !== -1)
  },
  arrayToStrDayTypes: (arr) => {
    let weekDays = ['Di', 'Lu', 'Ma', 'Me', 'Je', 'Ve', 'Sa']
    let str = []
    arr.map((dayActive, i) => {
      if(dayActive){
        str.push(weekDays[i])
      }
    })
    return str.join(',')
  },
  fetchingApi: () =>({
    type: 'FETCH_API'
  }),
  receiveErrors : (json) => ({
    type: "RECEIVE_ERRORS",
    json
  }),
  unavailableServer: () => ({
    type: 'UNAVAILABLE_SERVER'
  }),
  receiveMonth: (json) => ({
    type: 'RECEIVE_MONTH',
    json
  }),
  receiveTimeTables: (json) => ({
    type: 'RECEIVE_TIME_TABLES',
    json
  }),
  goToPreviousPage : (dispatch, pagination) => ({
    type: 'GO_TO_PREVIOUS_PAGE',
    dispatch,
    pagination,
    nextPage : false
  }),
  goToNextPage : (dispatch, pagination) => ({
    type: 'GO_TO_NEXT_PAGE',
    dispatch,
    pagination,
    nextPage : true
  }),
  changePage : (dispatch, pagination, val) => ({
    type: 'CHANGE_PAGE',
    dispatch,
    page: val
  }),
  updateDayTypes: (index) => ({
    type: 'UPDATE_DAY_TYPES',
    index
  }),
  updateComment: (comment) => ({
    type: 'UPDATE_COMMENT',
    comment
  }),
  updateColor: (color) => ({
    type: 'UPDATE_COLOR',
    color
  }),
  select2Tags: (selectedTag) => ({
    type: 'UPDATE_SELECT_TAG',
    selectedItem: {
      id: selectedTag.id,
      name: selectedTag.name
    }
  }),
  unselect2Tags: (selectedTag) => ({
    type: 'UPDATE_UNSELECT_TAG',
    selectedItem: {
      id: selectedTag.id,
      name: selectedTag.name
    }
  }),
  deletePeriod: (index, dayTypes) => ({
    type: 'DELETE_PERIOD',
    index,
    dayTypes
  }),
  openAddPeriodForm: () => ({
    type: 'OPEN_ADD_PERIOD_FORM'
  }),
  openEditPeriodForm: (period, index) => ({
    type: 'OPEN_EDIT_PERIOD_FORM',
    period,
    index
  }),
  closePeriodForm: () => ({
    type: 'CLOSE_PERIOD_FORM'
  }),
  updatePeriodForm: (val, group, selectType) => ({
    type: 'UPDATE_PERIOD_FORM',
    val,
    group,
    selectType
  }),
  validatePeriodForm: (modalProps, timeTablePeriods, metas) => ({
    type: 'VALIDATE_PERIOD_FORM',
    modalProps,
    timeTablePeriods,
    metas
  }),
  includeDateInPeriod: (index, day, dayTypes) => ({
    type: 'INCLUDE_DATE_IN_PERIOD',
    index,
    day,
    dayTypes
  }),
  excludeDateFromPeriod: (index, day, dayTypes) => ({
    type: 'EXCLUDE_DATE_FROM_PERIOD',
    index,
    day,
    dayTypes
  }),
  openConfirmModal : (callback) => ({
    type : 'OPEN_CONFIRM_MODAL',
    callback
  }),
  closeModal : () => ({
    type : 'CLOSE_MODAL'
  }),
  monthName(strDate) {
    let monthList = ["Janvier", "Février", "Mars", "Avril", "Mai", "Juin", "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"]
    var date = new Date(strDate)
    return monthList[date.getMonth()]
  },
  getHumanDate(strDate, mLimit) {
    let origin = strDate.split('-')
    let D = origin[2]
    let M = actions.monthName(strDate).toLowerCase()
    let Y = origin[0]

    if(mLimit && M.length > mLimit) {
      M = M.substr(0, mLimit) + '.'
    }

    return (D + ' ' + M + ' ' + Y)
  },

  updateSynthesis: (state, daytypes) => {
    let periods = state.time_table_periods

    let isInPeriod = function(d){
      let currentMonth = state.current_periode_range.split('-')
      let twodigitsDay = d.mday < 10 ? ('0' + d.mday) : d.mday
      let currentDate = new Date(currentMonth[0] + '-' + currentMonth[1] + '-' + twodigitsDay)

      // We compare periods & currentDate, to determine if it is included or not
      let testDate = false
      periods.map((p, i) => {
        if(p.deleted){
          return false
        }
        let begin = new Date(p.period_start)
        let end = new Date(p.period_end)

        if(testDate === false){
          if(currentDate >= begin && currentDate <= end) {
            if(daytypes[d.wday] === false) {
              testDate = false
            } else {
              testDate = true
            }
          }
        }
      })
      return testDate
    }

    let improvedCM = state.current_month.map((d, i) => {
      return _.assign({}, state.current_month[i], {
        in_periods: isInPeriod(state.current_month[i])
      })
    })
    return improvedCM
  },

  checkConfirmModal: (event, callback, stateChanged,dispatch) => {
    if(stateChanged === true){
      return actions.openConfirmModal(callback)
    }else{
      dispatch(actions.fetchingApi())
      return callback
    }
  },
  formatDate: (props) => {
    return props.year + '-' + props.month + '-' + props.day
  },
  checkErrorsInPeriods: (start, end, index, periods) => {
    let error = ''
    start = new Date(start)
    end = new Date(end)
    _.each(periods, (period, i) => {
      if(index != i){
        if((new Date(period.period_start) <= start && new Date(period.period_end) >= start) || (new Date(period.period_start) <= end && new Date(period.period_end) >= end))
        error = 'Les périodes ne peuvent pas se chevaucher'
      }
    })
    return error
  },
  fetchTimeTables: (dispatch, nextPage) => {
    let urlJSON = window.location.pathname.split('/', 5).join('/')
    // console.log(nextPage)
    if(nextPage) {
      urlJSON += "/month.json?date=" + nextPage
    }else{
      urlJSON += ".json"
    }
    let hasError = false
    fetch(urlJSON, {
      credentials: 'same-origin',
    }).then(response => {
        if(response.status == 500) {
          hasError = true
        }
        return response.json()
      }).then((json) => {
        if(hasError == true) {
          dispatch(actions.unavailableServer())
        } else {
          if(nextPage){
            dispatch(actions.receiveMonth(json))
          }else{
            dispatch(actions.receiveTimeTables(json))
          }
        }
      })
  },
  submitTimetable: (dispatch, timetable, metas, next) => {
    dispatch(actions.fetchingApi())
    let strDayTypes = actions.arrayToStrDayTypes(metas.day_types)
    metas.day_types= strDayTypes
    let sentState = _.assign({}, timetable, metas)
    let urlJSON = window.location.pathname.split('/', 5).join('/')
    let hasError = false
    fetch(urlJSON + '.json', {
      credentials: 'same-origin',
      method: 'PATCH',
      contentType: 'application/json; charset=utf-8',
      Accept: 'application/json',
      body: JSON.stringify(sentState),
      headers: {
        'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
      }
    }).then(response => {
        if(!response.ok) {
          hasError = true
        }
        return response.json()
      }).then((json) => {
        if(hasError == true) {
          dispatch(actions.receiveErrors(json))
        } else {
          if(next) {
            dispatch(next)
          } else {
            dispatch(actions.receiveTimeTables(json))
          }
        }
      })
  }
}

module.exports = actions
