package edu.cyclonicforce.fr.ui.controller;

import edu.cyclonicforce.fr.ui.lib.bashExecutor.ListModule;
import edu.cyclonicforce.fr.ui.metier.Module;
import edu.cyclonicforce.fr.ui.metier.ModuleType;
import edu.cyclonicforce.fr.ui.metier.Scenes;
import edu.cyclonicforce.fr.ui.view.ViewLoader;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.input.MouseEvent;
import javafx.scene.layout.FlowPane;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;

/**
 * Controller for the dashboard home view.
 */
public class DashboradHomeController implements DasboardController {
    /**
     * HBox containing diagnostic cards.
     */
    @FXML
    public HBox diagContainer;
    /**
     * Root VBox of the dashboard home.
     */
    @FXML
    public VBox rootVBox;
    @FXML
    public Button helpBtn, reportsBtn, diagsBtn, modulesBtn, viewModulesBtn;
    /**
     * Reference to the main application controller.
     */
    private AppController appController;
    private final Map<ModuleType, List<Module>> modulesByType;
    private List<DiagCardController> diagCardControllers = new ArrayList<>();

     /**
     * Constructor for the dashboard home controller.
     */
    public DashboradHomeController() {
        ListModule listModule = new ListModule();
        this.modulesByType = listModule.getModulesByType();
    }

    /**
     * Initializes the dashboard home controller by loading diagnostic cards.
     */
    @FXML
    public void initialize() {
        modulesByType.get(ModuleType.DIAGNOSTIC).stream()
                .sorted(Comparator.comparing(Module::getName, String.CASE_INSENSITIVE_ORDER))
                .forEach(module -> {
                    ViewLoader<DiagCardController> loader = new ViewLoader<>();
                    loader.load("/edu/cyclonicforce/fr/ui/fxml/DiagCard.fxml", appController);
                    diagCardControllers.add(loader.getController());
                    loader.getController().setModule(module);
                    loader.getController().setAppController(appController);
                    diagContainer.getChildren().add(loader.getRoot());
                });
    }

    @FXML
    public void handleClicked(MouseEvent event) {
        if (event.getSource() == helpBtn) {
            appController.setScene(Scenes.DASHBOARD_HELP);
        } else if (event.getSource() == reportsBtn) {
            appController.setScene(Scenes.DASHBOARD_REPORTS);
        } else if (event.getSource() == diagsBtn) {
            appController.setScene(Scenes.DASHBOARD_DIAGS);
        } else if (event.getSource() == modulesBtn || event.getSource() == viewModulesBtn) {
            appController.setScene(Scenes.DASHBOARD_MODULES);
        }
    }

    /**
     * Sets the main application controller.
     * @param appController the main application controller
     */
    @Override
    public void setAppController(AppController appController) {
        this.appController = appController;
        for (DiagCardController diagCardController : diagCardControllers) {
            diagCardController.setAppController(appController);
        }
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