package edu.cyclonicforce.fr.ui.controller;

import edu.cyclonicforce.fr.ui.metier.Diagnostic;
import edu.cyclonicforce.fr.ui.metier.Module;
import edu.cyclonicforce.fr.ui.metier.ScanType;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.text.Text;

/**
 * Controller for the diagnostic module card UI component.
 */
public class DiagCardController {
    /**
     * The title text of the diagnostic module.
     */
    @FXML
    public Text titleText;
    /**
     * The version text of the diagnostic module.
     */
    @FXML
    public Text versionText;
    /**
     * The author text of the diagnostic module.
     */
    @FXML
    public Text authorText;
    /**
     * The description text of the diagnostic module.
     */
    @FXML
    public Text descriptionText;
    /**
     * The button to start the diagnostic module.
     */
    @FXML
    public Button startButton;
    /**
     * The button to view details of the diagnostic module.
     */
    @FXML
    public Button detailButton;

    private AppController appController;
    private String moduleName;

    /**
     * Sets the module information to be displayed on the card.
     * @param module The diagnostic module whose information is to be displayed.
     */
    public void setModule(Module module) {
        titleText.setText(module.getName());
        this.moduleName = module.getName();
        versionText.setText(module.getVersion());
        authorText.setText("Par " + module.getAuthor());
        descriptionText.setText(module.getDescription());
    }

    public void setAppController(AppController appController) {
        this.appController = appController;
    }

    @FXML
    public void initialize() {
//        startButton.setOnAction(event -> {
//            System.out.println("Starting diagnostic scan for module: " + moduleName);
//            if (appController != null) {
//                appController.startScan(ScanType.DIAGNOSTIC, moduleName);
//            } else {
//                System.err.println("AppController is not set in DiagCardController.");
//            }
//        });
    }

    @FXML
    private void handleStartScan() {
        System.out.println("Clic détecté pour le module : " + moduleName);
        if (appController != null) {
            appController.startScan(ScanType.DIAGNOSTIC, moduleName);
        } else {
            System.err.println("Erreur : AppController est null dans DiagCardController");
        }
    }
}
