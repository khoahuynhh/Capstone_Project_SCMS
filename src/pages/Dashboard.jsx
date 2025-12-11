import FaceRecognition from '../features/face-recognition';
import ServerStatus from '../features/monitoring';
import TransactionsPanel from '../features/transactions';

const DashboardPage = () => (
  <>
    <FaceRecognition />
    <ServerStatus />
    <TransactionsPanel />
  </>
);

export default DashboardPage;
