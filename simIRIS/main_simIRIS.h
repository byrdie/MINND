/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/* 
 * File:   main_simIRIS.h
 * Author: byrdie
 *
 * Created on November 6, 2016, 3:16 PM
 */

#ifndef MAIN_SIMIRIS_H
#define MAIN_SIMIRIS_H

#include <stdio.h>
#include <iostream>
#include <QApplication>
#include <math.h>
#include <vector>

#include <opencv/cxcore.hpp>
#include <opencv/highgui.h>

#include <hdf5/serial/H5Cpp.h>

#include "qtDisplay.h"
#include "moses_forwardModel.h"

#define TRUTH_LAMBDA_PIX 64
#define TRUTH_ASPECT_RATIO  4
#define TRUTH_X_PIX (TRUTH_LAMBDA_PIX * TRUTH_ASPECT_RATIO)

#define PROB_LAMBDA_0 TRUTH_LAMBDA_PIX / 2
#define PROB_DECAY 8
#define PROB_NORM 1

#define WIN_SCALE 7

#define TRUTH_FILE "../../datasets/sim_train.h5"
#define INPUT_FILE "../../datasets/sim_input.h5"

void init_rand(unsigned long int seed);
void init_rand();

double prob(int l);

template<typename T> std::vector<T> flatten(const std::vector<std::vector<T>> &orig);

using namespace std;

using namespace H5;

#endif /* MAIN_SIMIRIS_H */

