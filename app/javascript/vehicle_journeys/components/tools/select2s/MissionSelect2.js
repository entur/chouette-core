import _ from 'lodash'
import React, { Component } from 'react'
import PropTypes from 'prop-types'
import Select2 from 'react-select2-wrapper'
import actions from '../../../actions'
import language from '../../../../helpers/select2/language'

// get JSON full path
let origin = window.location.origin
let path = window.location.pathname.split('/', 7).join('/')


export default class BSelect4 extends Component {
  constructor(props) {
    super(props)
    this.onSelect = this.onSelect.bind(this)
  }

  useAjax(){
    return this.props.values == undefined || this.props.values.length == 0
  }

  value(){
    let val = undefined
    if(this.props.isFilter) {
      val = this.props.filters.query.journeyPattern
    }
    else{
      if(this.props.selection.selectedJPModal){
        val = this.props.selection.selectedJPModal
      }
    }
    if(val){
      if(this.useAjax()){
        val = val.published_name
      }
      else{
        val = val.id
      }
    }
    return val
  }

  data(){
    if(!this.useAjax()){
      let values = [{}]
      values.push(...this.props.values)
      return values
    }
    if(this.props.isFilter){
      return [this.props.filters.query.journeyPattern.published_name]
    }

    return (this.props.selection.selectedJPModal) ? [this.props.selection.selectedJPModal.published_name] : undefined
  }

  onSelect(e){
    if(this.useAjax()){
      this.props.onSelect2JourneyPattern(e)
    }
    else{
      let option = e.currentTarget.options[e.currentTarget.selectedIndex]
      let data = JSON.parse(option.dataset.item)

      this.props.onSelect2JourneyPattern({params:
        {
          data: _.assign({}, e.params.data, data)
        }
      })
    }
  }

  options(){
    let options = {
      language,
      theme: 'bootstrap',
      width: '100%',
      escapeMarkup: function (markup) { return markup; },
      templateResult: formatRepo,
      placeholder: I18n.t('vehicle_journeys.vehicle_journeys_matrix.filters.journey_pattern'),
      allowClear: false,
      escapeMarkup: function (markup) { return markup; },
    }
    if(this.useAjax()){
      options = _.assign({}, options, {
        ajax: {
          url: origin + path + '/journey_patterns_collection.json',
          dataType: 'json',
          delay: '500',
          data: function(params) {
            return {
              q: { published_name_or_objectid_or_registration_number_cont: params.term},
            };
          },
          processResults: function(data, params) {
            return {
              results: data.map(
                item => _.assign(
                  {},
                  item,
                  { text: "<strong>" + item.published_name + " - " + item.short_id + "</strong><br/><small>" + item.registration_number + "</small>" }
                )
              )
            };
          },
          cache: true
        },
        minimumInputLength: 1
      })
    }
    return options
  }

  render() {
    return (
      <Select2
        data={this.data()}
        value={this.value()}
        onSelect={this.onSelect}
        multiple={false}
        ref='journey_pattern_id'
        className={!this.props.isFilter ? "vjCreateSelectJP" : null}
        required={!this.props.isFilter}
        options={this.options()}
      />
    )
  }
}

const formatRepo = (props) => {
  if(props.text) return props.text
}
