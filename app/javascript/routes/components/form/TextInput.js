import React, { Component } from 'react'
import PropTypes from 'prop-types'

const TextInput = ({inputId, inputName, labelText, value, required, onChange, hasError}) => {
  return (
    <div className={`form-group ${hasError && 'has-error'}` }>
      <label className={`col-sm-4 col-xs-5 control-label string ${required ? 'required' : ''}`} htmlFor={inputId}>
        {labelText} { required ? <abbr title="Champ requis">*</abbr> : null}
      </label>
      <div className="col-sm-8 col-xs-7">
        <input className={`form-control string ${required ? 'required' : ''}`} type="text" name={inputName} id={inputId} onChange={onChange} value={value}/>
        { hasError && <span className="help-block small">doit être rempli(e)</span> }
      </div>
  </div>
  )
}

export default TextInput