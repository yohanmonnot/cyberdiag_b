package edu.cyclonicforce.fr.ui.controller;

import edu.cyclonicforce.fr.ui.metier.Diagnostic;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.text.Text;

public class DiagCardController {
    @FXML
    public Text titleText;
    @FXML
    public Text versionText;
    @FXML
    public Text authorText;
    @FXML
    public Text descriptionText;
    @FXML
    public Text levelText;
    @FXML
    public Button startButton;
    @FXML
    public Button detailButton;

    public void setDiag(Diagnostic diag) {
        titleText.setText(diag.getTitle());
        versionText.setText(diag.getVersion());
        authorText.setText("Par " + diag.getAuthor());
        descriptionText.setText(diag.getDescription());
        levelText.setText("Niveau: " + diag.getLevel());
    }
}
