package edu.cyclonicforce.fr.ui.controller;

import edu.cyclonicforce.fr.ui.metier.DiagnosticReportModule;
import edu.cyclonicforce.fr.ui.metier.ModuleReturn;
import javafx.fxml.FXML;
import javafx.scene.paint.Color;
import javafx.scene.shape.Polygon;
import javafx.scene.text.Text;

public class DashboardReportDetailModuleController {
    @FXML
    public Text moduleNameText;
    @FXML
    public Text RecommendationText;
    @FXML
    public Polygon star1;
    @FXML
    public Polygon star2;
    @FXML
    public Polygon star3;
    @FXML
    public Polygon star4;
    @FXML
    public Polygon star5;
    @FXML
    public Text moduleScoreText;

    private Polygon[] stars;
    
    private AppController appController;
    private DiagnosticReportModule moduleReturn;

    @FXML
    public void initialize() {
        stars = new Polygon[]{star1, star2, star3, star4, star5};
        refresh();
    }

    public void setModuleData(DiagnosticReportModule moduleReturn) {
        this.moduleReturn = new DiagnosticReportModule(moduleReturn);
        refresh();
    }

    private void refresh() {
        if (moduleReturn != null) {
            moduleNameText.setText(moduleReturn.getName());
            if (moduleReturn.getExitCode() == 1) {
                RecommendationText.setText(moduleReturn.getError());
            } else {
                RecommendationText.setText(moduleReturn.getRecommendation());
            }
            setNote(moduleReturn.getScore());
        } else {
            moduleNameText.setText("N/A");
            RecommendationText.setText("N/A");
            setNote(0);
        }
    }

    private void setNote(int note) {
        final String NOTE_PATTERN = "%d/5";

        if (note < 1 || note > 5) {
            moduleScoreText.setText("N/A");
            for (Polygon star : stars) {
                star.setFill(Color.WHITE);
            }
        } else if (note <=2) {
            moduleScoreText.setText(String.format(NOTE_PATTERN, note));
            int i = 0;
            for (Polygon star : stars) {
                i++;
                if (i <= note) {
                    star.setFill(Color.RED);
                }
            }
        } else if (note <=4) {
            moduleScoreText.setText(String.format(NOTE_PATTERN, note));
            int i = 0;
            for (Polygon star : stars) {
                i++;
                if (i <= note) {
                    star.setFill(Color.YELLOW);
                }
            }
        } else {
            moduleScoreText.setText(String.format(NOTE_PATTERN, note));
            int i = 0;
            for (Polygon star : stars) {
                i++;
                if (i <= note) {
                    star.setFill(Color.GREEN);
                }
            }
        }
    }
}
