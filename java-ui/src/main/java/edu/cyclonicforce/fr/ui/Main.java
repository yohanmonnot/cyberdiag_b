package edu.cyclonicforce.fr.ui;

import edu.cyclonicforce.fr.ui.controller.AppController;
import edu.cyclonicforce.fr.ui.lib.bashExecutor.ListModule;
import edu.cyclonicforce.fr.ui.lib.bashExecutor.ModuleExecutor;
import edu.cyclonicforce.fr.ui.lib.util.SettingsSingleton;
import edu.cyclonicforce.fr.ui.metier.ModuleReturn;
import edu.cyclonicforce.fr.ui.metier.Module;
import edu.cyclonicforce.fr.ui.metier.Scenes;
import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.scene.layout.AnchorPane;
import javafx.stage.Stage;

import java.io.IOException;
import java.util.List;

/**
 * Principal JavaFX application class.
 */
public class Main extends Application {
    /**
     * Start method called by JavaFX runtime.
     * @param stage the primary stage
     * @throws IOException if loading FXML fails
     */
    @Override
    public void start(Stage stage) throws IOException {
        Scene scene = new Scene(new AnchorPane());

        stage.setTitle("CyberDiag");
        stage.setScene(scene);
        stage.setResizable(false);
        stage.setWidth(1600);
        stage.setHeight(920);
        stage.show();

        AppController appController = new AppController(stage);
        appController.setScene(Scenes.ACCUEIL);

//        System.out.println("Test de récupértion de la liste de modules");
//        ListModule listModule = new ListModule();
//        try {
//            listModule.run();
//            List<Module> modules = listModule.getModules();
//            System.out.println("Modules rcupérés :");
//            for (Module mod : modules) {
//                System.out.println(mod);
//            }
//        } catch (Exception e) {
//            System.out.println("Erreur lors de la récupération de la liste de modules : " + e.getMessage());
//            e.printStackTrace();
//        }
//
//        System.out.println("Test d'exec du module memoryUsage");
//        ModuleExecutor executor = new ModuleExecutor();
//        try {
//            ModuleReturn result = executor.runModule("memoryUsage", null);
//            System.out.println("Resultat du module memoryUsage :");
//            System.out.println(result);
//        } catch (Exception e) {
//            System.out.println("Erreur lors de l'exécution du module memoryUsage : " + e.getMessage());
//            e.printStackTrace();
//        }
    }

    /**
     * Main method to launch the application.
     * @param args command-line arguments
     */
    public static void main(String[] args) {
        SettingsSingleton.getInstance().parseArguments(args);
        launch();
    }
}