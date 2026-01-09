package edu.cyclonicforce.fr.ui.controller;

import edu.cyclonicforce.fr.ui.metier.Module;
import edu.cyclonicforce.fr.ui.metier.ScanType;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.text.Text;

public class ModuleCardController {
    @FXML
    public Text titleText;
    @FXML
    public Text versionText;
    @FXML
    public Text authorText;
    @FXML
    public Text descriptionText;
    @FXML
    public Button startButton;

    private AppController appController;

    public void setModule(Module module) {
        titleText.setText(module.getName());
        versionText.setText(module.getVersion());
        authorText.setText("Par " + module.getAuthor());
        descriptionText.setText(module.getDescription());
    }

    public void setAppController(AppController appController) {
        this.appController = appController;
    }

    @FXML
    public void initialize() {
        startButton.setOnAction(event -> {
            appController.launchScan(ScanType.MODULE, titleText.getText());
        });
    }
}
