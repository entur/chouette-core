import  { connect } from 'react-redux'
import RouteForm from '../components/form'
import {
  updateRouteFormInput,
  fetchUserPermissions,
  fetchOppositeRoutes
} from '../actions'
import {
  handleInputChange,
  getDirection,
  directionHandler,
  FETCH_ROUTE_SUCCESS,
  FETCH_ROUTE_ERROR,
} from '../reducers/route'

const mapStateToProps = ({ route, oppositeRoutes, formErrors, status }) => ({
  route,
  isOutbound: route.wayback === 'outbound',
  errors: formErrors.route,
  oppositeRoutesOptions: oppositeRoutes[route.wayback] || []
})

const mapDispatchToProps = (dispatch) => ({
  onUpdateName(e) {
    const newName = handleInputChange('name')(e.target.value)()
    dispatch(updateRouteFormInput(newName))
  },
  onUpdatePublishedName(e) {
    const newPublishedName = handleInputChange('published_name')(e.target.value)()
    dispatch(updateRouteFormInput(newPublishedName))
  },
  onUpdateDirection(e) {
    const newAtributes  = handleInputChange('wayback')(getDirection(e))()
    dispatch(updateRouteFormInput(newAtributes))
  },
  onUpdateOppositeRoute(e) {
    const newOppositeRouteId = handleInputChange('opposite_route_id')(parseInt(e.target.value) || undefined)()
    dispatch(updateRouteFormInput(newOppositeRouteId))
  }
})

const Route = connect(mapStateToProps,mapDispatchToProps)(RouteForm)

export default Route