package edu.cyclonicforce.fr.ui.controller;

import edu.cyclonicforce.fr.ui.view.ViewLoader;
import edu.cyclonicforce.fr.ui.metier.Module;
import javafx.fxml.FXML;
import javafx.scene.layout.FlowPane;
import javafx.scene.layout.VBox;

import java.util.ArrayList;
import java.util.List;

public class DashboardModulesController implements DasboardController {
    @FXML
    public VBox rootVBox;
    @FXML
    public FlowPane DiagContainer;

    private AppController appController;
    private final List<ModuleCardController> moduleCardControllers = new ArrayList<>();

    @FXML
    public void initialize() {

    }

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
