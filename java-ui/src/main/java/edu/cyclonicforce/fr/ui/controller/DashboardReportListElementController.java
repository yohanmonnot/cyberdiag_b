package edu.cyclonicforce.fr.ui.controller;

import edu.cyclonicforce.fr.ui.metier.DiagnosticReport;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
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
    @FXML
    public Button detailButton;

    private Polygon[] stars;
    private boolean checked = false;
    private int note = 0;
    private DiagnosticReport diagnosticReport;
    private AppController appController = null;

    @FXML
    public void initialize(){
        if (starOne != null && starTwo != null && starThree != null && starFour != null && starFive != null) {
            stars = new Polygon[]{starOne, starTwo, starThree, starFour, starFive};
        }

        checkBoxHBox.setOnMouseClicked(event -> toggleCheck());
        detailButton.setOnMouseClicked(event -> {
            if (appController != null) {
                appController.showReportDetail(diagnosticReport);
            } else {
                System.err.println("AppController is not set in DashboardReportListElementController.");
            }
        });

        refresh();
    }

    private void refresh(){
        if (diagnosticReport != null){
            nameText.setText(diagnosticReport.getReportName());
            dateNumberText.setText(String.format("%s - %d", diagnosticReport.getReportDate(), diagnosticReport.getNumber()));
            setNote(diagnosticReport.getOverallNote());
        } else {
            nameText.setText("N/A");
            dateNumberText.setText("N/A - N/A");
            setNote(0);
        }
        intializeCheckbox();
    }

    private void intializeCheckbox(){
        checked = false;
        checkBoxHBox.setStyle("-fx-background-color: " + CHECKBOX_UNCHECKED_COLOR);
        checkBoxImage.setVisible(false);
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

    private void setNote(int note) {
        final String NOTE_PATTERN = "%d/5";
        this.note = note;

        if (note < 1 || note > 5) {
            this.note = 0;
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

    public void setAppController(AppController appController){
        this.appController = appController;
        refresh();
    }

    public int getNote(){
        return this.note;
    }

    public boolean isChecked(){
        return this.checked;
    }

    public void setDiagnosticReport(DiagnosticReport diagnosticReport){
        this.diagnosticReport = diagnosticReport;
        refresh();
    }
}
