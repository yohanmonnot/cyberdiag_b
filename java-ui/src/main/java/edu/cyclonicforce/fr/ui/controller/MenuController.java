package edu.cyclonicforce.fr.ui.controller;

import edu.cyclonicforce.fr.ui.metier.Scenes;
import javafx.fxml.FXML;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;
import javafx.scene.text.Text;

/**
 * Controller for the side menu in the dashboard.
 */
public class MenuController {
    /**
     * The burger button used to toggle the side menu. 
     */
    @FXML private HBox burgerButton;
    /**
     * The diagnostics button in the side menu.
     */
    @FXML private HBox diagnosticsButton;
    /**
     * The modules button in the side menu.
     */
    @FXML private HBox modulesButton;
    /**
     * The reports button in the side menu.
     */
    @FXML private HBox reportsButton;
    /**
     * The help button in the side menu.
     */
    @FXML private HBox helpButton;
    /**
     * The settings button in the side menu.
     */
    @FXML private HBox settingsButton;
    /**
     * The text label for the settings button.
     */
    @FXML private Text settingsText;
    /**
     * The text label for the help button.
     */
    @FXML private Text helpText;
    /**
     * The text label for the reports button.
     */
    @FXML private Text reportsText;
    /**
     * The text label for the modules button.
     */
    @FXML private Text modulesText;

    /**
     * The text label for the diagnostics button.
     */
    @FXML private Text diagnosticsText;
    /**
     * The VBox containing the entire menu.
     */
    @FXML private VBox menuVBox;
    /**
     * The main application controller.
     */
    private AppController appController;

    /**
     * Initializes the menu controller by setting up event handlers for the buttons.
     */
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

    /**
     * Sets the main application controller.
     * @param appController The main application controller.
     */
    public void setAppController(AppController appController) {
        this.appController = appController;
    }

    /**
     * Sets the menu to expanded or collapsed mode.
     * @param expanded True for expanded mode, false for collapsed mode.
     */
    public void setExpandedMode(boolean expanded) {
        if (expanded) {
            menuVBox.setPrefWidth(300);
            setLabelsVisible(true);
        } else {
            menuVBox.setPrefWidth(100);
            setLabelsVisible(false);
        }
    }

    /**
     * Sets the visibility of the text labels in the menu.
     * @param visible True to show the labels, false to hide them.
     */
    private void setLabelsVisible(boolean visible) {
        setTextState(diagnosticsText, visible);
        setTextState(modulesText, visible);
        setTextState(reportsText, visible);
        setTextState(helpText, visible);
        setTextState(settingsText, visible);
    }

    /**
     * Sets the visibility and managed state of a Text element.
     * @param text The Text element to modify.
     * @param visible True to make it visible, false to hide it.
     */
    private void setTextState(Text text, boolean visible) {
        text.setVisible(visible);
        text.setManaged(visible);
    }

    /**
     * Navigates to the specified scene.
     * @param scene The scene to navigate to.
     */
    private void navigateTo(Scenes scene) {
        if (appController != null) appController.setScene(scene);
    }
}