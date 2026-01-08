package edu.cyclonicforce.fr.ui.controller;

import edu.cyclonicforce.fr.ui.metier.Module;
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
    @FXML
    public Button detailButton;

    public void setModule(Module module) {
        titleText.setText(module.getName());
        versionText.setText(module.getVersion());
        authorText.setText("Par " + module.getAuthor());
        descriptionText.setText(module.getDescription());
    }
}
