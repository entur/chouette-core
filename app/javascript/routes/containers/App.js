import  { connect } from 'react-redux'
import AppComponent from '../components/App'
import { isActionCreate } from '../reducers/status' 
import {
  fetchRoute,
  fetchUserPermissions,
  fetchOppositeRoutes
} from '../actions'

const mapStateToProps = state => ({
  isActionUpdate: !isActionCreate(state.status)
})

const mapDispatchToProps = dispatch => ({
  onLoadFirstPage(mustFetchRoute) {
    fetchUserPermissions(dispatch)
    fetchOppositeRoutes(dispatch)
    mustFetchRoute && fetchRoute(dispatch)
  }
})

const App = connect (mapStateToProps, mapDispatchToProps)(AppComponent)

export default App