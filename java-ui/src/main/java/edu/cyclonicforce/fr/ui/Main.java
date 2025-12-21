package edu.cyclonicforce.fr.ui;

import edu.cyclonicforce.fr.ui.lib.bashExecutor.ListModule;
import edu.cyclonicforce.fr.ui.lib.bashExecutor.ModuleExecutor;
import edu.cyclonicforce.fr.ui.lib.util.SettingsSingleton;
import edu.cyclonicforce.fr.ui.metier.ModuleReturn;
import edu.cyclonicforce.fr.ui.metier.Module;
import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.stage.Stage;

import java.io.IOException;
import java.util.List;

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

        System.out.println("Test de récupértion de la liste de modules");
        ListModule listModule = new ListModule();
        try {
            List<Module> modules = listModule.run();
            System.out.println("Modules rcupérés :");
            for (Module mod : modules) {
                System.out.println(mod);
            }
        } catch (Exception e) {
            System.out.println("Erreur lors de la récupération de la liste de modules : " + e.getMessage());
            e.printStackTrace();
        }

        System.out.println("Test d'exec du module memoryUsage");
        ModuleExecutor executor = new ModuleExecutor();
        try {
            ModuleReturn result = executor.runModule("memoryUsage", null);
            System.out.println("Resultat du module memoryUsage :");
            System.out.println(result);
        } catch (Exception e) {
            System.out.println("Erreur lors de l'exécution du module memoryUsage : " + e.getMessage());
            e.printStackTrace();
        }
    }

    public static void main(String[] args) {
        SettingsSingleton.getInstance().parseArguments(args);
        launch();
    }
}