package edu.cyclonicforce.fr.ui.controller;

import javafx.fxml.FXML;
import javafx.scene.layout.FlowPane;
import javafx.scene.layout.VBox;

import java.util.List;

public class DiagnosticsController implements DasboardController {
    @FXML
    public VBox rootVBox;
    @FXML
    public FlowPane DiagContainer;

    private AppController appController;
    private List<DiagCardController> diagCardControllers;

    @FXML
    public void initialize() {
        // Initialisation des diagnostics ou autres configurations si nécessaire
    }

    private void loadDiagnostics() {
        // Logique pour charger et afficher les diagnostics dans DiagContainer
    }

    @Override
    public void setAppController(AppController appController) {
        this.appController = appController;
    }

    @Override
    public void toggleSize(boolean menuState) {
        if (menuState) {
            rootVBox.setMinWidth(1300);
            rootVBox.setPrefWidth(1300);
            rootVBox.setMaxWidth(1300);
        } else {
            rootVBox.setMinWidth(1500);
            rootVBox.setPrefWidth(1500);
            rootVBox.setMaxWidth(1500);
        }
    }
}
