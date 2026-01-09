package edu.cyclonicforce.fr.ui.controller;

import edu.cyclonicforce.fr.ui.lib.bashExecutor.ModuleExecutor;
import edu.cyclonicforce.fr.ui.metier.ModuleReturn;
import edu.cyclonicforce.fr.ui.metier.ModuleType;
import edu.cyclonicforce.fr.ui.metier.ScanType;
import edu.cyclonicforce.fr.ui.metier.Module;
import javafx.fxml.FXML;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;
import javafx.scene.paint.Color;
import javafx.scene.shape.StrokeType;
import javafx.scene.text.Font;
import javafx.scene.text.Text;

import java.util.List;
import java.util.Map;

public class InScanController {
    @FXML
    public Text progressText;
    @FXML
    public HBox progressBar;
    @FXML
    public VBox logContainer;

    private static final String MODULE_START_MESSAGE = "Démarrage du madule %s...";
    private static final String MODULE_END_MESSAGE = "Module %s terminé.";
    private static final String DIAG_CATEGORY_START_MESSAGE = "Démarrage de la catégorie de diagnostic %s...";
    private static final String DIAG_CATEGORY_END_MESSAGE = "Catégorie de diagnostic %s terminée.";

    private AppController appController;

    private Map<ModuleType, List<Module>> modulesByType;

    @FXML
    public void initialize() {
        logContainer.getChildren().clear();
    }

    public void setAppController(AppController appController) {
        this.appController = appController;
    }

    public void startScan(ScanType scanType, String moduleName) {
        if (appController != null) {
            this.modulesByType = appController.getModulesByType();
        }

        if (scanType == ScanType.DIAGNOSTIC) {
            System.out.println("Starting diagnostic scan for module: " + moduleName);
            System.out.println("Pas encore implémenté");
        } else if (scanType == ScanType.MODULE) {
            List<Module> modules = modulesByType.get(ModuleType.TOOL);
            for (Module module : modules) {
                if (module.getName().equals(moduleName)) {
                    System.out.println(moduleName);
                    startModule(module);
                    break;
                }
            }
        }
    }

    private void startModule(Module module) {
        ModuleExecutor executor = new ModuleExecutor();
        try {
            addPageLog(String.format(MODULE_START_MESSAGE, module.getName()));
            System.out.println(module.toString());
            System.out.println(String.format(MODULE_START_MESSAGE, module.getName()));
            ModuleReturn result = executor.runModule(module.getName(), null);

            System.out.println(String.format(MODULE_END_MESSAGE, module.getName()));
            addPageLog(String.format(MODULE_END_MESSAGE, module.getName()));
            addPageLog(result.toString());
        } catch (Exception e) {
            addPageLog("Erreur lors de l'exécution du module " + module.getName() + " : " + e.getMessage());
            e.printStackTrace();
        }
    }

    private void startDiag(Module diag) {

    }

    private void addPageLog(String message) {
        Text logText = new Text(message);

        logText.setFill(Color.WHITE);
        logText.setStrokeType(StrokeType.OUTSIDE);
        logText.setStrokeWidth(0.0);
        logText.setWrappingWidth(1468.0);
        logText.setFont(Font.font(36.0));

        logContainer.getChildren().add(logText);
    }
}
