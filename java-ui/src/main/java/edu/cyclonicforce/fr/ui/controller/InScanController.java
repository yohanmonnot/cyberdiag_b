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

/**
 * Controller for the InScan view.
 */
public class InScanController {
    /**
     * Text displaying the progress percentage of the scan.
     */
    @FXML
    public Text progressText;
    /**
     * Progress bar container.
     */
    @FXML
    public HBox progressBar;
    /**
     * Container for log messages during the scan.
     */
    @FXML
    public VBox logContainer;
    /**
     * Message templates for module and diagnostic category start and end.
     */
    private static final String MODULE_START_MESSAGE = "Démarrage du madule %s...";
    /**
     * Message templates for module and diagnostic category start and end.
     */
    private static final String MODULE_END_MESSAGE = "Module %s terminé.";
    /**
     * Message templates for module and diagnostic category start and end.
     */
    private static final String DIAG_CATEGORY_START_MESSAGE = "Démarrage de la catégorie de diagnostic %s...";
    /**
     * Message templates for module and diagnostic category start and end.
     */
    private static final String DIAG_CATEGORY_END_MESSAGE = "Catégorie de diagnostic %s terminée.";
    /**
     * Reference to the main application controller.
     */
    private AppController appController;
    /**
     * Map of modules categorized by their type.
     */
    private Map<ModuleType, List<Module>> modulesByType;

    /**
     * Initializes the controller.
     */
    @FXML
    public void initialize() {
        logContainer.getChildren().clear();
    }

    /**
     * Sets the main application controller.
     * @param appController the main application controller
     */
    public void setAppController(AppController appController) {
        this.appController = appController;
    }

    /**
     * Starts a scan based on the specified type and module name.
     * @param scanType the type of scan to perform
     * @param moduleName the name of the module to scan
     */
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

    /**
     * Starts the specified module and logs its execution.
     * @param module the module to start
     */
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

    /**
     * Executes the specified diagnostic.
     * @param diag the diagnostic to execute
     */
    private void startDiag(Module diag) {

    }

    /**
     * Adds a log message to the page.
     * @param message the log message to add
     */
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
