package edu.cyclonicforce.fr.ui.controller;

import javafx.fxml.FXML;
import javafx.scene.control.Label;

public class ExempleController {

    // L'élément Label que nous avons défini avec fx:id="welcomeText" dans le FXML
    @FXML
    private Label welcomeText;

    // La méthode appelée lorsque le bouton est cliqué (onAction="#onButtonClick")
    @FXML
    protected void onButtonClick() {
        // Logique de l'application
        System.out.println("Le bouton a été cliqué ! Mise à jour du texte...");

        // Mise à jour de l'interface utilisateur
        welcomeText.setText("Bouton cliqué ! Vérifiez la console.");
    }
}