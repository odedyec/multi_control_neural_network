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


class RBFLayer(Layer):
    def __init__(self, units, gamma, **kwargs):
        super(RBFLayer, self).__init__(**kwargs)
        self.units = units
        self.gamma = K.cast_to_floatx(gamma)

    def build(self, input_shape):
        self.mu = self.add_weight(name='mu',
                                  shape=(int(input_shape[1]), self.units),
                                  initializer='uniform',
                                  trainable=True)
        super(RBFLayer, self).build(input_shape)

    def call(self, inputs):
        diff = K.expand_dims(inputs) - self.mu
        l2 = K.sum(K.pow(diff,2), axis=1)
        res = K.exp(-1 * self.gamma * l2)
        return res

    def compute_output_shape(self, input_shape):
        return (input_shape[0], self.units)


mat_file = 'mcnn_net.mat'

scaler_filename1 = "scaler_x.save"
scaler_filename2 = "scaler_y.save"


NUM_OF_STATES = 6
NUM_OF_CONVS = 4
DATA_FILE = 'data_{}_{}.csv'.format(NUM_OF_STATES, NUM_OF_CONVS)  # 'data_6_100.csv'
OUTPUT_FILE = 'mcnn_classi_{}_{}.h5'.format(NUM_OF_STATES, NUM_OF_CONVS)


def build_classifier():
    classifier = Sequential()
    classifier.add(Dense(output_dim=10*NUM_OF_CONVS, input_dim=NUM_OF_STATES, activation='relu'))
    # classifier.add(Dense(NUM_OF_CONVS, activation='relu'))
    classifier.add(Dense(3*NUM_OF_CONVS, activation='relu'))
    classifier.add(Dense(NUM_OF_CONVS, activation='softmax'))
    classifier.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])
    return classifier


def build_rbf_classifier():
    classifier = Sequential()
    classifier.add(Dense(output_dim=20, input_dim=NUM_OF_STATES, activation='relu'))
    classifier.add(Dense(20, activation='relu'))
    classifier.add(RBFLayer(10, 0.5))
    classifier.add(Dense(NUM_OF_CONVS, activation='softmax'))
    classifier.compile(optimizer='adam', loss='mse', metrics=['accuracy'])
    return classifier


def build_conv_classifier():
    classifier = Sequential()
    classifier.add(Conv2D(10*NUM_OF_CONVS, kernel_size=(NUM_OF_STATES, 1), padding='valid',activation='relu', input_shape=(NUM_OF_STATES, 1, 1), name = 'conv_layer'))
    # classifier.add(
    #     Conv2D(10, kernel_size=1, padding='valid', activation='relu'))
    classifier.add(Flatten())
    # classifier.add(Dense(output_dim=10, input_dim=NUM_OF_STATES, activation='relu'))
    # classifier.add(Dense(NUM_OF_CONVS, activation='relu'))
    classifier.add(Dense(3*NUM_OF_CONVS, activation='relu'))
    classifier.add(Dense(output_dim=NUM_OF_CONVS, activation='softmax'))
    classifier.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])
    return classifier


def load_data(verbose=False):
    X = []
    y = []
    import os
    path = os.path.abspath(__file__).split('mcnn_classification.py')[0]
    with open(path+DATA_FILE, 'r') as f:
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
    #sc_x = MinMaxScaler()
    #sc_y = MinMaxScaler()
    #X_sc = sc_x.fit_transform(X)
    #y_sc = sc_y.fit_transform(y)

    #joblib.dump(sc_x, scaler_filename1)
    #joblib.dump(sc_y, scaler_filename2)

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3)


    # classifier = KerasClassifier(build_fn=build_conv_classifier, epochs=1000, batch_size=72, verbose=1)
    # X = X.reshape((len(X), NUM_OF_STATES, 1, 1))
    classifier = KerasClassifier(build_fn=build_classifier, epochs=100, batch_size=72, verbose=1)
    res  = classifier.fit(X, y)



    y_pred = classifier.predict(X)
    y_pred2 =  classifier.predict_proba(X)
    # y_pred_s = sc_y.inverse_transform(y_pred)
    classifier.model.save(OUTPUT_FILE)
    y_pred_list = list(y_pred)
    y_label_list = list(map(lambda x: int(x[0]-1), y_lab))
    # print y_pred_list
    # print y_label_list
    # print list(map(lambda x: x[0]-x[1], zip(y_pred_list, y_label_list)))
    # print('||E|| = {}'.format(np.sum(np.sum(np.abs(y_lab - y_pred) ** 2, axis=0) ** (1./2))))
    return res.history['acc'][-1]


def load_and_test():
    dat = {}
    X, y = load_data()
    sc_x = joblib.load(scaler_filename1)
    sc_y = joblib.load(scaler_filename2)

    dat['inp_min'] = sc_x.data_min_
    dat['inp_max'] = sc_x.data_max_
    dat['out_min'] = sc_y.data_min_
    dat['out_max'] = sc_y.data_max_

    regressor = KerasRegressor(build_fn=build_regressor, verbose=1)
    regressor.model = load_model('mcnn.h5')
    Ws = []
    bs = []
    for layer_i in range(len(regressor.model.layers)):
        w = regressor.model.layers[layer_i].get_weights()[0]
        b = regressor.model.layers[layer_i].get_weights()[1]
        print('Layer %s has weights of shape %s and biases of shape %s' % (
            layer_i, np.shape(w), np.shape(b)))
        Ws.append(w)
        bs.append(b)
    y_pred = regressor.predict(sc_x.transform(X))
    y_pred_s = sc_y.inverse_transform(y_pred)
    dat['num_of_layers'] = len(regressor.model.layers)
    dat['W'] = Ws
    dat['b'] = bs
    sio.savemat(mat_file, dat)
    print('||E|| = {}'.format(np.sum(np.sum(np.abs(y - y_pred) ** 2, axis=0) ** (1. / 2))))


import time
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