package edu.cyclonicforce.fr.ui.controller;

import javafx.fxml.FXML;
import javafx.scene.image.ImageView;
import javafx.scene.layout.HBox;
import javafx.scene.paint.Color;
import javafx.scene.shape.Polygon;
import javafx.scene.text.Text;

public class DashboardReportListElementController {
    private final String CHECKBOX_CHECKED_COLOR = "#057AA4";
    private final String CHECKBOX_UNCHECKED_COLOR = "WHITE";

    @FXML
    public HBox checkBoxHBox;
    @FXML
    public ImageView checkBoxImage;
    @FXML
    public Text dateNumberText; // format DD/MM/YYYY - number
    @FXML
    public Text nameText;
    @FXML
    public Polygon starOne;
    @FXML
    public Polygon starTwo;
    @FXML
    public Polygon starThree;
    @FXML
    public Polygon starFour;
    @FXML
    public Polygon starFive;
    @FXML
    public Text noteText;

    private Polygon[] stars;
    private boolean checked = false;
    private int note = 0;

    @FXML
    public void initialize(){
        if (starOne != null && starTwo != null && starThree != null && starFour != null && starFive != null) {
            stars = new Polygon[]{starOne, starTwo, starThree, starFour, starFive};
        }

        checkBoxHBox.setStyle("-fx-background-color: " + CHECKBOX_UNCHECKED_COLOR);
        checkBoxImage.setVisible(false);

        checkBoxHBox.setOnMouseClicked(event -> {toggleCheck();});
    }

    private void toggleCheck(){
        checked = !checked;
        if(checked){
            checkBoxHBox.setStyle("-fx-background-color: " + CHECKBOX_CHECKED_COLOR);
            checkBoxImage.setVisible(true);
        } else {
            checkBoxHBox.setStyle("-fx-background-color: " + CHECKBOX_UNCHECKED_COLOR);
            checkBoxImage.setVisible(false);
        }
    }

    public void setNote(int note) {
        final String NOTE_PATTERN = "%d/5";

        if (note < 1 || note > 5) {
            noteText.setText("N/A");
            for (Polygon star : stars) {
                star.setFill(Color.WHITE);
            }
        } else if (note <=2) {
            noteText.setText(String.format(NOTE_PATTERN, note));
            int i = 0;
            for (Polygon star : stars) {
                i++;
                if (i <= note) {
                star.setFill(Color.RED);
                }
            }
        } else if (note <=4) {
            noteText.setText(String.format(NOTE_PATTERN, note));
            int i = 0;
            for (Polygon star : stars) {
                i++;
                if (i <= note) {
                    star.setFill(Color.YELLOW);
                }
            }
        } else {
            noteText.setText(String.format(NOTE_PATTERN, note));
            int i = 0;
            for (Polygon star : stars) {
                i++;
                if (i <= note) {
                    star.setFill(Color.GREEN);
                }
            }
        }
    }

    public int getNote(){
        return this.note;
    }

    public boolean isChecked(){
        return this.checked;
    }
}
