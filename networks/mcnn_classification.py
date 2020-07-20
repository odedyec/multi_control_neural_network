import numpy as np
import matplotlib.pyplot as plt
# %matplotlib inline

from keras import Sequential
from keras.layers import Dense, Conv2D, Flatten
from keras.wrappers.scikit_learn import KerasRegressor, KerasClassifier
from keras.models import load_model

from sklearn.preprocessing import  MinMaxScaler
from sklearn.model_selection import train_test_split
from sklearn.externals import joblib

import scipy.io as sio
from keras.layers import Layer
from keras import backend as K
import yaml

import time
import os


path = os.path.abspath(__file__).split('mcnn_classification.py')[0]
with open(path+'mcnn_config.yaml') as stream:
     config_dict = yaml.safe_load(stream)

NUM_OF_STATES = config_dict['states']
NUM_OF_CONVS = config_dict['controllers']
DATA_FILE = path + 'mcnn_data_{}_{}.csv'.format(NUM_OF_STATES, NUM_OF_CONVS)  # 'data_6_100.csv'
OUTPUT_FILE = path + 'mcnn_classi_{}_{}.h5'.format(NUM_OF_STATES, NUM_OF_CONVS)
layers = config_dict['layers']
nb_epochs = config_dict['epochs']
nb_batch  = config_dict['batch_size']
tst_size  = config_dict['train_test_split']

def build_classifier():
    classifier = Sequential()
    classifier.add(Dense(output_dim=layers[0], input_dim=NUM_OF_STATES, activation='relu', name='l0'))
    for i, layer in enumerate(layers):
        if i == 0:
            continue
        if layer == 0:
            continue
        classifier.add(Dense(layer, activation='relu', name='l{}'.format(i)))
    classifier.add(Dense(NUM_OF_CONVS, activation='softmax', name='l_final'))
    classifier.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])
    return classifier


def load_data(verbose=False):
    X = []
    y = []
    with open(DATA_FILE, 'r') as f:
        i = 0
        while True:
            x = f.readline()
            x = x.rstrip()
            if not x: break
            line_list = map(float, x.split(','))
            X.append(line_list[0:NUM_OF_STATES])
            y.append(line_list[NUM_OF_STATES:])
            i += 1
        if verbose:
            print ('There are {} samples in the dataset'.format(i))
    Y = np.zeros((len(X), NUM_OF_CONVS))
    for i, yy in enumerate(y):
        Y[i, int(yy[0])-1] = 1
    if verbose:
        print ('X: {}x{}   y: {}x{}'.format(len(X), len(X[0]), len(Y), len(Y[0])))
    X = np.array(X)
    return X, Y, y


def run_and_save():
    X, y, y_lab = load_data()
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=tst_size)

    classifier = KerasClassifier(build_fn=build_classifier, epochs=nb_epochs, batch_size=nb_batch, verbose=1)
    res  = classifier.fit(X, y)



    #y_pred = classifier.predict(X)
    pred_start_time = time.time()
    y_pred2 =  classifier.predict_proba(X)
    stop_time = time.time()
    print ("Pred time for {} samples is {} seconds. CTPS={}".format(len(X), stop_time - pred_start_time, (stop_time - pred_start_time) / len(X)))
    
    classifier.model.save(OUTPUT_FILE)
    return res.history['acc'][-1]


now = time.time()
for i in range(1):
    print run_and_save(),
print time.time() - now
# load_and_test()
#
# fig, ax = plt.subplots()
# ax.scatter(y_test, y_pred)
# ax.plot([y_test.min(), y_test.max()], [y_test.min(), y_test.max()], 'k--', lw=4)
# ax.set_xlabel('Measured')
# ax.set_ylabel('Predicted')
# plt.show()
