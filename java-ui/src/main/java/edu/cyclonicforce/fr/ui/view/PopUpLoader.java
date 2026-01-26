package edu.cyclonicforce.fr.ui.view;

import edu.cyclonicforce.fr.ui.controller.AppController;
import edu.cyclonicforce.fr.ui.controller.PopUpController;
import edu.cyclonicforce.fr.ui.metier.PopUpData;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;

import java.io.IOException;

public class PopUpLoader {
    private Parent root;
    private PopUpController controller;

    public void load(PopUpData popUpData) {
        try {
            FXMLLoader loader = new FXMLLoader(getClass().getResource(popUpData.getFxmlPath()));
            this.root = loader.load();
            this.controller = loader.getController();
            if (controller != null) {
                controller.setPopUpData(popUpData);
            }
        } catch (IOException e) {
            throw new RuntimeException("Impossible de charger " + popUpData.getFxmlPath(), e);
        }
    }

    public Scene getScene() {
        return new Scene(root);
    }

    public PopUpController getController() {
        return controller;
    }
}
