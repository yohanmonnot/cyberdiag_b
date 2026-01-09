package edu.cyclonicforce.fr.ui.controller;

import edu.cyclonicforce.fr.ui.view.ViewLoader;
import javafx.fxml.FXML;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;

import java.util.ArrayList;
import java.util.List;

/**
 * Controller for the dashboard home view.
 */
public class DashboradHomeController implements DasboardController {
    /**
     * HBox containing diagnostic cards.
     */
    @FXML
    public HBox diagnosticCardsHBox;
    /**
     * Root VBox of the dashboard home.
     */
    @FXML
    private VBox rootVBox;
    /**
     * Reference to the main application controller.
     */
    private AppController appController;
    /**
     * List of diagnostic card controllers.
     */
    private final List<DiagCardController> diagCardControllers = new ArrayList<>();

    /**
     * Initializes the dashboard home controller by loading diagnostic cards.
     */
    @FXML
    public void initialize() {
        ViewLoader<DiagCardController> loader = new ViewLoader<>();
        for (int i = 0; i < 2; i++) {
            loader.load("/edu/cyclonicforce/fr/ui/fxml/DiagCard.fxml", appController);
            diagCardControllers.add(loader.getController());
            diagnosticCardsHBox.getChildren().add(loader.getRoot());
        }
    }

    /**
     * Sets the main application controller.
     * @param appController the main application controller
     */
    @Override
    public void setAppController(AppController appController) {
        this.appController = appController;
    }

    /**
     * Toggles the size of the dashboard home based on the menu state.
     * @param menuState true if the menu is open, false otherwise
     */
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