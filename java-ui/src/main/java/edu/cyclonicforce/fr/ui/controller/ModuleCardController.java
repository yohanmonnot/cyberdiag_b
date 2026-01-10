package edu.cyclonicforce.fr.ui.controller;

import edu.cyclonicforce.fr.ui.metier.Module;
import edu.cyclonicforce.fr.ui.metier.ScanType;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.text.Text;

/**
 * Controller for the module card UI component.
 */
public class ModuleCardController {
    /**
     * Title text of the module.
     */
    @FXML
    public Text titleText;
    /**
     * Version text of the module.
     */
    @FXML
    public Text versionText;
    /**
     * Author text of the module.
     */
    @FXML
    public Text authorText;
    /**
     * Description text of the module.
     */
    @FXML
    public Text descriptionText;
    /**
     * Start button to launch the module scan.
     */
    @FXML
    public Button startButton;
    /**
     * Reference to the main application controller.
     */
    private AppController appController;

    /**
     * Sets the module information to be displayed on the card.
     * @param module the module whose information is to be displayed
     */
    public void setModule(Module module) {
        titleText.setText(module.getName());
        versionText.setText(module.getVersion());
        authorText.setText("Par " + module.getAuthor());
        descriptionText.setText(module.getDescription());
    }

    /**
     * Sets the reference to the main application controller.
     * @param appController the main application controller
     */
    public void setAppController(AppController appController) {
        this.appController = appController;
    }

    /**
     * Initializes the controller and sets up event handlers.
     */
    @FXML
    public void initialize() {
        startButton.setOnAction(event -> {
            appController.startScan(ScanType.MODULE, titleText.getText());
        });
    }
}
