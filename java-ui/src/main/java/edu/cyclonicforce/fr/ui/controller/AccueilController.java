package edu.cyclonicforce.fr.ui.controller;

import edu.cyclonicforce.fr.ui.metier.Scenes;
import javafx.fxml.FXML;
import javafx.scene.layout.VBox;

/**
 * Controller for the "Accueil" view.
 */
public class AccueilController {
    /**
     * Reference to the main application controller.
     */
    private AppController appController;

    /**
     * Button to start the application.
     */
    @FXML
    private VBox boutonCommencer;

    /**
     * Button to start the application in questionnaire mode.
     */
    @FXML
    private VBox boutonQuestionnaire;

    /**
     * Sets the main application controller.
     * 
     * @param appController The main application controller.
     */
    public void setAppController(AppController appController) {
        this.appController = appController;
    }

    /**
     * Handles the click event on the "Commencer" button.
     */
    @FXML
    public void onCommencerClicked() {
        if (appController != null) {
            appController.setScene(Scenes.DASHBOARD);
        } else {
            System.err.println("Erreur : AppController est null dans AccueilController");
        }
    }

    /**
     * Handles the click event on the "Questionnaire" button.
     */
    @FXML
    public void onQuestionnaireClicked() {
        if (appController != null) {
            appController.setScene(Scenes.QUESTIONNAIRE);
        } else {
            System.err.println("Erreur : AppController est null dans AccueilController");
        }
    }
}