package edu.cyclonicforce.fr.ui.controller;

import edu.cyclonicforce.fr.ui.view.ViewLoader;
import edu.cyclonicforce.fr.ui.metier.Module;
import javafx.fxml.FXML;
import javafx.scene.layout.FlowPane;
import javafx.scene.layout.VBox;

import java.util.ArrayList;
import java.util.List;

/**
 * Controller for the Dashboard Modules view.
 */
public class DashboardModulesController implements DasboardController {
    /**
     * Root VBox of the dashboard modules view.
     */
    @FXML
    public VBox rootVBox;
    /**
     * Container for the module cards.
     */
    @FXML
    public FlowPane DiagContainer;
    /**
     * Reference to the main application controller.
     */
    private AppController appController;
    /**
     * List of module card controllers.
     */
    private final List<ModuleCardController> moduleCardControllers = new ArrayList<>();

    /**
     * Initializes the controller.
     */
    @FXML
    public void initialize() {

    }

    /**
     * Sets the list of modules to be displayed.
     * @param moduleList List of modules to display
     */
    public void setModuleList(List<Module> moduleList) {
        moduleCardControllers.clear();
        DiagContainer.getChildren().clear();
        for (Module m : moduleList) {
            ViewLoader<ModuleCardController> loader = new ViewLoader<>();
            loader.load("/edu/cyclonicforce/fr/ui/fxml/ModuleCard.fxml", appController);
            loader.getController().setModule(m);
            moduleCardControllers.add(loader.getController());
            DiagContainer.getChildren().add(loader.getRoot());
        }
    }

    /**
     * Sets the application controller.
     * @param appController The main application controller
     */
    @Override
    public void setAppController(AppController appController) {
        this.appController = appController;
    }

    /**
     * Toggles the size of the dashboard based on the menu state.
     * @param menuState The current state of the menu
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
