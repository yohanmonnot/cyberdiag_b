module edu.cyclonicforce.fr.java.ui {
    requires javafx.controls;
    requires javafx.fxml;
    requires com.google.gson;

    // OUVRE le package de la CLASSE MAIN (si elle lance le FXML)
    opens edu.cyclonicforce.fr.ui to javafx.fxml;

    // NOUVEAU : OUVRE le package du CONTROLLER
    // Le FXMLoader doit pouvoir accéder à ce package
    opens edu.cyclonicforce.fr.ui.controller to javafx.fxml;

    opens edu.cyclonicforce.fr.ui.lib.bashExecutor to com.google.gson;
    opens edu.cyclonicforce.fr.ui.metier to com.google.gson;

    // EXPORTE le package de la classe Main pour qu'il soit accessible depuis le JAR
    exports edu.cyclonicforce.fr.ui;
}