/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/* 
 * File:   qtDisplay.h
 * Author: byrdie
 *
 * Created on November 6, 2016, 4:20 PM
 */

#ifndef QTDISPLAY_H
#define QTDISPLAY_H

#include <QApplication>
#include <QGraphicsScene>
#include <QGraphicsView>
#include <QGraphicsItem>

using namespace std;

class qtDisplay {
public:
    uint x_pix = 512;
    uint y_pix = 512;
    
    QGraphicsScene * scene;
    QGraphicsView * view;
    QPixmap pixmap;
     QGraphicsPixmapItem * tile;
    
    qtDisplay();
    void show(vector<vector<double>> img);
};

#endif /* QTDISPLAY_H */

