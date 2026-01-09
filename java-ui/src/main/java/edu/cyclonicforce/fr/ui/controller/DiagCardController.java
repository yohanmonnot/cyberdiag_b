package edu.cyclonicforce.fr.ui.controller;

import edu.cyclonicforce.fr.ui.metier.Diagnostic;
import edu.cyclonicforce.fr.ui.metier.Module;
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

    /**
     * Sets the module information to be displayed on the card.
     * @param module The diagnostic module whose information is to be displayed.
     */
    public void setModule(Module module) {
        titleText.setText(module.getName());
        versionText.setText(module.getVersion());
        authorText.setText("Par " + module.getAuthor());
        descriptionText.setText(module.getDescription());
    }
}
