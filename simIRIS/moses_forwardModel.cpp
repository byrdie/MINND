
#include "moses_forwardModel.h"

vector<vector<float>> moses_fomod(vector<vector<float>> lcube_slice) {

    uint x_pix = lcube_slice.size();
    uint lambda_pix = lcube_slice[0].size();

    

    /* Construct positive order */
    vector<float> pos(x_pix - lambda_pix);
    for (uint i = 0; i < x_pix - lambda_pix; i++) {
        for (uint j = 0; j < lambda_pix; j++) {
            uint k = j + i;
            pos[i] += lcube_slice[k][j];
        }
    }

    /* Flip the spectral slice about x to construct minus order */
    reverse(lcube_slice.begin(), lcube_slice.end());
    vector<float> neg(x_pix - lambda_pix);
    for (uint i = 0; i < x_pix - lambda_pix; i++) {
        for (uint j = 0; j < lambda_pix; j++) {
            uint k = j + i;
            neg[i] += lcube_slice[k][j];
        }
    }

    /* flip it back */
    reverse(lcube_slice.begin(), lcube_slice.end());
    reverse(neg.begin(), neg.end());

    /* Construct the zeroth order */
    vector<float> zero(x_pix - lambda_pix);
    for (uint i = lambda_pix / 2; i < (x_pix - (lambda_pix / 2)); i++) {
        for (uint j = 0; j < lambda_pix; j++) {
            zero[i - lambda_pix / 2] += lcube_slice[i][j];
        }
    }

    /* Combine the three orders into one narrow image */
    vector<vector<float> > moses;
    moses.push_back(pos);
    moses.push_back(zero);
    moses.push_back(neg);



    return moses;
    
}

