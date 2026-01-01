package edu.cyclonicforce.fr.ui.controller;

import edu.cyclonicforce.fr.ui.metier.Scenes;
import edu.cyclonicforce.fr.ui.view.AccueilLoader;
import javafx.scene.Scene;
import javafx.stage.Stage;

public class AppController {
    Stage mainStage;

    public AppController(Stage mainStage) {
        if (mainStage==null) {
            throw new IllegalArgumentException("main stage cannot be null");
        }
        this.mainStage=mainStage;
    }

    public void init() {
        Scene acceuilScene = new AccueilLoader().load();
        this.mainStage.setTitle("CyberDiag");
        this.mainStage.setScene(acceuilScene);
        this.mainStage.show();
    }

    public void setScene(Scenes sceneToDisplay) {
        switch (sceneToDisplay) {
            case ACCEUIL -> {
                Scene acceuilScene = new AccueilLoader().load();
                this.mainStage.setTitle("CyberDiag - Acceuil");
                this.mainStage.setScene(acceuilScene);
            }
        }
    }
}
