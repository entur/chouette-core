import React, { Component } from 'react'
import PropTypes from 'prop-types'

const SelectInput = ({inputId, inputName, value, labelText, onChange, options}) => {

  const renderOptions = () => {
    return options.reduce((array, route) => {
      return array.concat (<option key={route.id} value={route.id} value={route.id === value}>{route.name}</option>)
    }, [<option key='blank' value=''></option>])
  }
  return (
    <div className="form-group opposite_route inbound">
      <label className="col-sm-4 col-xs-5 control-label select optional" htmlFor={inputId}>
        {labelText}
      </label>
      <div className="col-sm-8 col-xs-7">
        <select className="form-control select optional" name={inputName} id={inputId} onChange={onChange}>
          { renderOptions() }
        </select>
      </div>
    </div>
  )
}

export default SelectInput