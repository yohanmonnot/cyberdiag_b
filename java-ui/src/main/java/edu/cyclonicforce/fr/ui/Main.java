package edu.cyclonicforce.fr.ui;

import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.stage.Stage;

import java.io.IOException;

public class Main extends Application {

    @Override
    public void start(Stage stage) throws IOException {

        // 1. Charger le fichier FXML
        // Notez le chemin relatif pour accéder au FXML dans le même package que le contrôleur (ui/)
        FXMLLoader fxmlLoader = new FXMLLoader(Main.class.getResource("/edu/cyclonicforce/fr/ui/fxml/Exemple.fxml"));

        // 2. Créer la scène avec la vue chargée
        Scene scene = new Scene(fxmlLoader.load(), 320, 240);

        // 3. Configurer et afficher la fenêtre (Stage)
        stage.setTitle("Mon Application JavaFX !");
        stage.setScene(scene);
        stage.show();
    }

    public static void main(String[] args) {
        // Méthode de lancement de l'application JavaFX
        launch();
    }
}