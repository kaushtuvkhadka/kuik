#include "mainwindow.h"

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent) {
    setWindowTitle("Movie Player");
    resize(800, 600);
}

MainWindow::~MainWindow() {}
