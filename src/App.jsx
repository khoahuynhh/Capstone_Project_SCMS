import './App.css'
import FaceRecognition from './components/FaceRecognition'
import ServerStatus from './components/ServerStatus'
import TransactionsPanel from './components/TransactionsPanel'

function App() {
  return (
    <>
      <FaceRecognition />
      <ServerStatus />
      <TransactionsPanel />
    </>
  )
}

export default App
