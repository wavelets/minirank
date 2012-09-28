from tempfile import mkstemp
from sklearn import datasets
import _sofia_ml

def train(X, y, alpha, query_id):
    """
    bla bla
    """
    fd, file_name = mkstemp()
    datasets.dump_svmlight_file(X, y, file_name)#, query_id=query_id)
    return _sofia_ml.train(file_name, X.shape[1], alpha)