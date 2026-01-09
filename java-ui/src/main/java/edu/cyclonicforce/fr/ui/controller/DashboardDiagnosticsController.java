package edu.cyclonicforce.fr.ui.controller;

import edu.cyclonicforce.fr.ui.metier.Module;
import edu.cyclonicforce.fr.ui.view.ViewLoader;
import javafx.fxml.FXML;
import javafx.scene.layout.FlowPane;
import javafx.scene.layout.VBox;

import java.util.ArrayList;
import java.util.List;

/**
 * Controller for the diagnostics dashboard section.
 */
public class DashboardDiagnosticsController implements DasboardController {
    /**
     * Root VBox container for the diagnostics dashboard.
     */
    @FXML
    public VBox rootVBox;
    /**
     * FlowPane container for diagnostic cards.
     */
    @FXML
    public FlowPane DiagContainer;
    /**
     * Reference to the main application controller.
     */
    private AppController appController;
    /**
     * List of diagnostic card controllers.
     */
    private final List<DiagCardController> diagCardControllers = new ArrayList<>();

    /**
     * Initializes the diagnostics dashboard controller.
     */
    @FXML
    public void initialize() {

    }

    /**
     * Sets the list of diagnostic modules to be displayed.
     * @param diagList List of diagnostic modules
     */
    public void setDiagList(List<Module> diagList) {
        diagCardControllers.clear();
        DiagContainer.getChildren().clear();
        for (Module m : diagList) {
            ViewLoader<DiagCardController> loader = new ViewLoader<>();
            loader.load("/edu/cyclonicforce/fr/ui/fxml/DiagCard.fxml", appController);
            loader.getController().setModule(m);
            diagCardControllers.add(loader.getController());
            DiagContainer.getChildren().add(loader.getRoot());
        }
    }

    /**
     * Sets the main application controller.
     * @param appController The main application controller
     */
    @Override
    public void setAppController(AppController appController) {
        this.appController = appController;
    }

    /**
     * Toggles the size of the diagnostics dashboard based on the menu state.
     * @param menuState True if the menu is collapsed, false otherwise
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
