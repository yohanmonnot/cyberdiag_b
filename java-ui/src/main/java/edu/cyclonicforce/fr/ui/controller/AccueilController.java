package edu.cyclonicforce.fr.ui.controller;

import edu.cyclonicforce.fr.ui.metier.Scenes; // N'oublie pas l'import
import javafx.fxml.FXML;
import javafx.scene.layout.VBox;

public class AccueilController {

    private AppController appController;

    @FXML
    private VBox boutonCommencer;

    public void setAppController(AppController appController) {
        this.appController = appController;
    }

    // C'est cette méthode qui sera appelée par le FXML
    @FXML
    public void onCommencerClicked() {
        if (appController != null) {
            // On demande à passer sur le Dashboard (le AppController gérera la vue par défaut)
            appController.setScene(Scenes.DASHBOARD);
        } else {
            System.err.println("Erreur : AppController est null dans AccueilController");
        }
    }
}