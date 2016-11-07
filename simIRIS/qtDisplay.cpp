
#include "qtDisplay.h"

qtDisplay::qtDisplay() {

    scene = new QGraphicsScene(0, 0, x_pix, y_pix);
    view = new QGraphicsView(scene);
    view->setBackgroundBrush(QBrush(Qt::black, Qt::SolidPattern));
//    view->resize(512,512);
    view->show();

}

void qtDisplay::show(vector<vector<double>> img) {

    /* Find the maximum value in the image */
    double max = 0.0;
    for (uint i = 0; i < img.size(); i++) {
        vector<double> row = img[i];
        for (uint j = 0; j < row.size(); j++) {
            double val = row[j];
            if (val > max) {
                max = val;
            }
        }
    }

    /* scale the image to between 0 and 255 */
    vector<uchar> scaled_img;
    for (uint i = 0; i < img.size(); i++) {
        vector<double> row = img[i];
        for (uint j = 0; j < row.size(); j++) {
            double val = row[j];
            unsigned char scaled_val = (uint) ((val / max) * 255);
            scaled_img.push_back(scaled_val);
            scaled_img.push_back(scaled_val);
            scaled_img.push_back(scaled_val);
        }
    }

    pixmap = QPixmap::fromImage(QImage(scaled_img.data(),img.size(),img[0].size(),QImage::Format_RGB888));
    
//    QPixmap * spixmap = new QPixmap(pixmap.scaled(((double)x_pix)/(double)img.size(), ((double)y_pix)/(double)img[0].size(), Qt::KeepAspectRatio));
//    QPixmap * spixmap = new QPixmap(pixmap.scaled(1.0, 1.0, Qt::KeepAspectRatio));

    tile = new QGraphicsPixmapItem(0, scene);
    tile->setPixmap(pixmap);
    tile->setOffset(0,0);
    tile->setZValue(1);
    view->show();
    qApp->processEvents();
}