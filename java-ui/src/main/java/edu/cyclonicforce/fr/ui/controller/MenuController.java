package edu.cyclonicforce.fr.ui.controller;

import edu.cyclonicforce.fr.ui.metier.Scenes;
import javafx.fxml.FXML;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;
import javafx.scene.text.Text;

public class MenuController {

    @FXML private HBox burgerButton;
    @FXML private HBox diagnosticsButton;
    @FXML private HBox modulesButton;
    @FXML private HBox reportsButton;
    @FXML private HBox helpButton;
    @FXML private HBox settingsButton;

    @FXML private Text settingsText;
    @FXML private Text helpText;
    @FXML private Text reportsText;
    @FXML private Text modulesText;
    @FXML private Text diagnosticsText;

    @FXML private VBox menuVBox;

    private AppController appController;

    @FXML
    public void initialize() {
        burgerButton.setOnMouseClicked(event -> {
            if (appController != null) appController.toggleMenu();
        });

        diagnosticsButton.setOnMouseClicked(e -> navigateTo(Scenes.DASHBOARD_DIAGS));
        modulesButton.setOnMouseClicked(e -> navigateTo(Scenes.DASHBOARD_MODULES));
        reportsButton.setOnMouseClicked(e -> navigateTo(Scenes.DASHBOARD_REPORTS));
        helpButton.setOnMouseClicked(e -> navigateTo(Scenes.DASHBOARD_HELP));
        settingsButton.setOnMouseClicked(e -> navigateTo(Scenes.DASHBOARD_SETTINGS));
    }

    public void setAppController(AppController appController) {
        this.appController = appController;
    }

    public void setExpandedMode(boolean expanded) {
        if (expanded) {
            menuVBox.setPrefWidth(300);
            setLabelsVisible(true);
        } else {
            menuVBox.setPrefWidth(100);
            setLabelsVisible(false);
        }
    }

    private void setLabelsVisible(boolean visible) {
        setTextState(diagnosticsText, visible);
        setTextState(modulesText, visible);
        setTextState(reportsText, visible);
        setTextState(helpText, visible);
        setTextState(settingsText, visible);
    }

    private void setTextState(Text text, boolean visible) {
        text.setVisible(visible);
        text.setManaged(visible);
    }

    private void navigateTo(Scenes scene) {
        if (appController != null) appController.setScene(scene);
    }
}