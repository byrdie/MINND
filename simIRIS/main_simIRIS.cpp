/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/*
 * File:   main_simIRIS.cpp
 * Author: byrdie
 *
 * Created on November 6, 2016, 2:08 PM
 */

#include <vector>

#include "main_simIRIS.h"

int main(int argc, char *argv[]) {
    // initialize resources, if needed
    // Q_INIT_RESOURCE(resfile);

    //    QApplication app(argc, argv);

    /* initialize repeatable random number generation */
    init_rand();

    /* Create space for truth image (spectral cube slice) */
    vector<vector<float> > truth;


    /* Loop through truth and activate random pixels based off of probability
     * distribution P(x) = A exp(-d|lambda-lambda_0|) */
    for (uint i = 0; i < TRUTH_X_PIX; i++) { // Loop through x dimension

        vector<float> next_row;

        for (uint j = 0; j < TRUTH_LAMBDA_PIX; j++) { // Loop through lambda dimension

            /* Calculate the probability at this value of lambda*/
            float P = prob(j);

            /* select a new random number */
            float is_active = (float) rand() / (float) INT_MAX;

            /* Activate pixel if random number is smaller*/
            float next_val;
            if (is_active < P) {
                next_val = is_active;
            } else {
                next_val = 0.0;
            }
            next_row.push_back(next_val);
        }
        truth.push_back(next_row);
    }

    /* Apply a blur effect to the pixels */
    for (uint i = 0; i < TRUTH_X_PIX; i++) {
        for (uint j = 1; j < TRUTH_LAMBDA_PIX - 1; j++) {
            if (i != 0 and i != TRUTH_X_PIX - 1) {
                truth[i][j] = (truth[i + 1][j + 1] + truth[i + 1][j] + truth[i + 1][j - 1] + truth[i][j + 1] + truth[i][j - 1] + truth[i - 1][j + 1] + truth[i - 1][j] + truth[i - 1][j - 1]) / 8.0;
            } else if (i == 0) {
                truth[i][j] = (truth[i + 1][j + 1] + truth[i + 1][j] + truth[i + 1][j - 1] + truth[i][j + 1] + truth[i][j - 1]) / 5.0;
            } else {
                truth[i][j] = (truth[i][j + 1] + truth[i][j - 1] + truth[i - 1][j + 1] + truth[i - 1][j] + truth[i - 1][j - 1]) / 5.0;

            }
        }
    }

    /* Save a subset of truth to HDF5 dataset */
    vector<vector<float>> ctruth;
    for (uint i = TRUTH_LAMBDA_PIX; i < TRUTH_X_PIX - TRUTH_LAMBDA_PIX; i++) {
        vector<float> row;
        for (uint j = 0; j < TRUTH_LAMBDA_PIX; j++) {
            row.push_back(truth[i][j]);
        }
        ctruth.push_back(row);
    }

    /* flatten */
    vector<float> ftruth = flatten(ctruth);

    /* Create the HDF5 file */
    const H5std_string FILE_NAME(TRUTH_FILE);
    const H5std_string DATASET_NAME("Truth");
    const int NX = TRUTH_X_PIX - (2 * TRUTH_LAMBDA_PIX); // dataset dimensions
    const int NY = TRUTH_LAMBDA_PIX;
    const int RANK = 2;
    H5::H5File file(FILE_NAME, H5F_ACC_TRUNC);
    hsize_t dimsf[2]; // dataset dimensions
    dimsf[0] = NX;
    dimsf[1] = NY;
    DataSpace dataspace(RANK, dimsf);
    FloatType datatype(PredType::NATIVE_FLOAT);
    datatype.setOrder(H5T_ORDER_LE);
    DataSet dataset = file.createDataSet( DATASET_NAME, datatype, dataspace );
    dataset.write( ftruth.data(), PredType::NATIVE_FLOAT );

    /* Run forward model */
    vector<vector<float>> moses = moses_fomod(truth);



    /* bitmap for checking projections */
    uint x_pix = TRUTH_X_PIX;
    uint lambda_pix = TRUTH_LAMBDA_PIX;
    cv::Mat moses_image = cv::Mat(3, x_pix - lambda_pix, CV_32F, 0.0);
    for (uint i = 0; i < 3; i++) {
        for (uint j = 0; j < x_pix - lambda_pix; j++) {
            moses_image.at<float>(i, j) = moses[i][j] / 5;
        }
    }

    /* Window for checking projections */
    cv::namedWindow("Projections Image", cv::WINDOW_NORMAL);
    cv::imshow("Projections Image", moses_image);
    cv::resizeWindow("Projections Image", (x_pix - lambda_pix) * 7, 3);
    cv::moveWindow("Projections Image", WIN_SCALE * lambda_pix / 2, WIN_SCALE * lambda_pix);

    /* Convert to an openCV bitmap for viewing */
    cv::Mat truth_image = cv::Mat(TRUTH_LAMBDA_PIX, TRUTH_X_PIX, CV_32F);
    for (uint i = 0; i < TRUTH_X_PIX; i++) {
        for (uint j = 0; j < TRUTH_LAMBDA_PIX; j++) {
            truth_image.at<float>(j, i) = truth[i][j];
        }
    }

    cv::namedWindow("Truth Image", cv::WINDOW_NORMAL);
    cv::imshow("Truth Image", truth_image);
    cv::resizeWindow("Truth Image", TRUTH_X_PIX * WIN_SCALE, TRUTH_LAMBDA_PIX * WIN_SCALE);
    cv::moveWindow("Truth Image", 0, 0);





    cv::waitKey(0);


    //    /* Open Qt window and show the result */
    //    qtDisplay * win = new qtDisplay();
    //    win->show(truth);
    //    


    // create and show your widgets here

    //    return app.exec();
    return 0;
}

double prob(int l) {

    return PROB_NORM * exp((-1) *((double) abs(l - PROB_LAMBDA_0)) / PROB_DECAY);

}

/* Prepare random number generation */
void init_rand(unsigned long int seed) {
    srand(seed);
    printf("Seed: %lu\n", seed);
}

void init_rand() {
    unsigned int seed = time(NULL);
    srand(seed);
    printf("Seed: %u\n", seed);
}

template<typename T> std::vector<T> flatten(const std::vector<std::vector<T>> &orig) {
    std::vector<T> ret;
    for (const auto &v : orig)
        ret.insert(ret.end(), v.begin(), v.end());
    return ret;
} 