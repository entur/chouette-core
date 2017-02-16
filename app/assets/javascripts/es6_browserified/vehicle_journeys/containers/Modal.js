var connect = require('react-redux').connect
var EditModal = require('../components/EditModal')
var CreateModal = require('../components/CreateModal')
var actions = require('../actions')

const mapStateToProps = (state) => {
  return {
    modal: state.modal,
    journeyPattern: state.journeyPattern
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    onModalClose: () =>{
      dispatch(actions.closeModal())
    }
  }
}

const ModalContainer = connect(mapStateToProps, mapDispatchToProps)(CreateModal)

module.exports = ModalContainer
