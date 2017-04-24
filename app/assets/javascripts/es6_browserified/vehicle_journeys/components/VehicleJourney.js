var React = require('react')
var Component = require('react').Component
var PropTypes = require('react').PropTypes

class VehicleJourney extends Component {
  constructor(props) {
    super(props)
    this.previousCity = undefined
  }

  cityNameChecker(sp) {
    let bool = false
    if(sp.stop_area_cityname != this.previousCity){
      bool = true
      this.previousCity = sp.stop_area_cityname
    }
    return bool
  }

  timeTableURL(id) {
    let refURL = window.location.pathname.split('/', 3).join('/')
    let ttURL = refURL + '/time_tables/' + id

    return (
      <a href={ttURL} title='Voir le calendrier'><span className='fa fa-calendar'></span></a>
    )
  }

  columnHasDelta() {
    let a = []
    this.props.value.vehicle_journey_at_stops.map((vj, i) => {
      a.push(vj.delta)
    })
    let b = a.reduce((p, c) => p+c, 0)

    if(b > 0) {
      return true
    }
  }

  isDisabled(bool1, bool2) {
    return (bool1 || bool2)
  }

  render() {
    this.previousCity = undefined

    return (
      <div className={'t2e-item' + (this.props.value.deletable ? ' disabled' : '')}>
        <div className='th'>
          <div className='strong mb-xs'>{this.props.value.objectid ? this.props.value.objectid : '-'}</div>
          <div>{this.props.value.journey_pattern.objectid}</div>
          {this.props.value.time_tables.map((tt, i)=>
            <div key={i}>{this.timeTableURL(tt.id)}</div>
          )}

          {(this.props.filters.policy['vehicle_journeys.edit'] == true) &&
            <div className={(this.props.value.deletable ? 'disabled ' : '') + 'checkbox'}>
              <input
                id={this.props.index}
                name={this.props.index}
                onChange={(e) => this.props.onSelectVehicleJourney(this.props.index)}
                type='checkbox'
                disabled={this.props.value.deletable}
                checked={this.props.value.selected}
              ></input>
              <label htmlFor={this.props.index}></label>
            </div>
        }

        </div>
        {this.props.value.vehicle_journey_at_stops.map((vj, i) =>
          <div key={i} className='td text-center'>
            <div className={'cellwrap' + (vj.dummy ? ' headlined' : '') + (this.cityNameChecker(vj) ? ' headlined' : '')}>
              {this.props.filters.toggleArrivals &&
                <div data-headline='Arrivée à'>
                  <span className={((this.isDisabled(this.props.value.deletable, vj.dummy) || this.props.filters.policy['vehicle_journeys.edit'] == false) ? 'disabled ' : '') + 'input-group time'}>
                    <input
                      type='number'
                      min='00'
                      max='23'
                      className='form-control'
                      disabled={(this.isDisabled(this.props.value.deletable, vj.dummy) || this.props.filters.policy['vehicle_journeys.edit'] == false)}
                      onChange={(e) => {this.props.onUpdateTime(e, i, this.props.index, 'hour', false, false)}}
                      value={vj.arrival_time['hour']}
                      />
                    <span>:</span>
                    <input
                      type='number'
                      min='00'
                      max='59'
                      className='form-control'
                      disabled={((this.isDisabled(this.props.value.deletable), vj.dummy) || this.props.filters.policy['vehicle_journeys.edit'] == false)}
                      onChange={(e) => {this.props.onUpdateTime(e, i, this.props.index, 'minute', false, false)}}
                      value={vj.arrival_time['minute']}
                      />
                  </span>
                </div>
                }
                <div className={(this.columnHasDelta() ? '' : 'hidden')}>
                  {(vj.delta != 0) &&
                    <span className='sb sb-chrono sb-lg text-warning' data-textinside={vj.delta}></span>
                  }
                </div>
                <div data-headline='Départ à'>
                  <span className={((this.isDisabled(this.props.value.deletable, vj.dummy) || this.props.filters.policy['vehicle_journeys.edit'] == false) ? 'disabled ' : '') + 'input-group time'}>
                    <input
                      type='number'
                      min='00'
                      max='23'
                      className='form-control'
                      disabled={(this.isDisabled(this.props.value.deletable, vj.dummy) || this.props.filters.policy['vehicle_journeys.edit'] == false)}
                      onChange={(e) => {this.props.onUpdateTime(e, i, this.props.index, 'hour', true, this.props.filters.toggleArrivals)}}
                      value={vj.departure_time['hour']}
                      />
                    <span>:</span>
                    <input
                      type='number'
                      min='00'
                      max='59'
                      className='form-control'
                      disabled={(this.isDisabled(this.props.value.deletable, vj.dummy) || this.props.filters.policy['vehicle_journeys.edit'] == false)}
                      onChange={(e) => {this.props.onUpdateTime(e, i, this.props.index, "minute", true,  this.props.filters.toggleArrivals)}}
                      value={vj.departure_time['minute']}
                      />
                  </span>
                </div>
            </div>
          </div>
        )}
      </div>
    )
  }
}

VehicleJourney.propTypes = {
  value: PropTypes.object.isRequired,
  filters: PropTypes.object.isRequired,
  index: PropTypes.number.isRequired,
  onUpdateTime: PropTypes.func.isRequired,
  onSelectVehicleJourney: PropTypes.func.isRequired
}

module.exports = VehicleJourney
