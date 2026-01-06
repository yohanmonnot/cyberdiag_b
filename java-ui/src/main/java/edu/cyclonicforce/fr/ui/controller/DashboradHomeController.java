package edu.cyclonicforce.fr.ui.controller;

import javafx.fxml.FXML;
import javafx.scene.layout.VBox;

public class DashboradHomeController implements DasboardController {
    @FXML
    private VBox rootVBox;

    private AppController appController;

    @Override
    public void setAppController(AppController appController) {
        this.appController = appController;
    }

    @Override
    public void toggleSize(boolean menuOpen) {
        if (menuOpen) {
            rootVBox.setPrefWidth(1300);
        } else {
            rootVBox.setPrefWidth(1500);
        }
    }
}