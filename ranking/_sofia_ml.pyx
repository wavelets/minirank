# distutils: language = c++
# distutils: sources = ranking/src/sofia-ml-methods.cc ranking/src/{sf-weight-vector.cc,sf-data-set.cc}
from cython.operator cimport dereference as deref
from libcpp cimport bool
from libcpp.string cimport string

cimport numpy as np
import numpy as np

BUFFER_MB = 40 # default in sofia-ml

cdef extern from "src/sofia-ml-methods.h":
    cdef cppclass SfDataSet:
        SfDataSet(bool)
        SfDataSet(string, int, bool)

    cdef cppclass SfWeightVector:
        SfWeightVector(int)
        string AsString()
        float ValueOf(int)

cdef extern from "src/sofia-ml-methods.h" namespace "sofia_ml":
    cdef enum LearnerType:
        PEGASOS, MARGIN_PERCEPTRON, PASSIVE_AGGRESSIVE, LOGREG_PEGASOS,
        LOGREG, LMS_REGRESSION, SGD_SVM, ROMMA

    cdef enum EtaType:
        BASIC_ETA
        PEGASOS_ETA
        CONSTANT

    void StochasticRankLoop(SfDataSet training_set,
          LearnerType,
          EtaType,
          float, float, int, SfWeightVector*)

def train(train_data, int n_features, float alpha, int max_iter=100, bool fit_intercept=True):
    cdef SfDataSet *data = new SfDataSet(train_data, BUFFER_MB, fit_intercept)
    cdef SfWeightVector *w = new SfWeightVector(n_features)
    cdef float c = 0.0
    cdef int i
    StochasticRankLoop(deref(data), SGD_SVM, BASIC_ETA, alpha, c, max_iter, w)
    cdef np.ndarray[ndim=1, dtype=np.float64_t] coef = np.empty(n_features)
    for i in range(n_features):
        coef[i] = w.ValueOf(i)
    return coef
