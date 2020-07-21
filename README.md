# Multi-controller and Neural network multi controller

This is a matlab library for MC and NNMC control schemes.
You will also need to use the MPT library.

You Need Matlab 2018 or newer

There are pretrained networks in the `networks` folder. 
You can train your own model if you have Python and Keras installed.

## How to run
Run the script `ex1.m` from the root of the folder.

* Note that it is important to run from the root because of the paths to the folder `networks`

## Training your own network
Generate an NNMC controller 
```
cont_mcnn = NeuralNetworkMultiController(n, m, gu, ListOfControllers, ListOfConvHulls); 
```
Design a fully contected layer network, and train:
```
layers = [8, 16, 8]; # Hidden layers only. If you want only one hidden layer write [8, 0]
epochs = 100;
cont_mcnn.train_network(layers, epochs)
```
A config file and dataset file will be generated in the network folder.
If you have Python and Keras installed, the Python script in network will 
automatically start and train. You will see the progress in the Matlab's terminal.

Finally you will see the accuracy, train time, and CTPS. 
In addition, the network file will be saved in the network folder. 

All files will have a name prefix_STATES_NUMBEROFCONTROLLERS.extension

## Load a network
Run the following line:
```
cont_mcnn.load_network();
```
The network will automatically load the network file that has the number of states and the number of controllers.


