package edu.cyclonicforce.fr.ui.view;

public class AccueilLoader implements ViewLoader {
    @Override
    public javafx.scene.Scene load() {
        try {
            javafx.fxml.FXMLLoader fxmlLoader = new javafx.fxml.FXMLLoader(getClass().getResource("/edu/cyclonicforce/fr/ui/fxml/Accueil.fxml"));
            return new javafx.scene.Scene(fxmlLoader.load());
        } catch (java.io.IOException e) {
            e.printStackTrace();
        }

        return null;
    }
}
