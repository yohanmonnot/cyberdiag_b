package edu.cyclonicforce.fr.ui.view;

import edu.cyclonicforce.fr.ui.controller.AppController;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;

import java.io.IOException;
import java.lang.reflect.InvocationTargetException;

/**
 * Generic class to load FXML views and their controllers.
 * @param <T> The type of the controller associated with the FXML view.
 */
public class ViewLoader<T> {
    /**
     * The controller associated with the loaded FXML view.
     */
    private T controller;
    /**
     * The root node of the loaded FXML view.
     */
    private Parent root;

    /**
     * Loads an FXML view and its controller.
     * @param fxmlPath The path to the FXML file.
     * @param appController The main application controller to be passed to the loaded controller.
     */
    public void load(String fxmlPath , AppController appController) {
        try {
            FXMLLoader loader = new FXMLLoader(getClass().getResource(fxmlPath));
            this.root = loader.load();
            this.controller = loader.getController();

            // Si le contrôleur a une méthode setAppController, on l'appelle
            try {
                controller.getClass()
                          .getMethod("setAppController", AppController.class)
                          .invoke(controller, appController);
            } catch (NoSuchMethodException | IllegalAccessException | InvocationTargetException e) {
                // La méthode n'existe pas, on ne fait rien
            } catch (Exception e) {
                // Autres exceptions potentielles lors de l'invocation
            }
        } catch (IOException e) {
            throw new RuntimeException("Impossible de charger " + fxmlPath, e);
        }
    }

    /**
     * Gets the root node of the loaded FXML view.
     * @return The root node.
     */
    public Parent getRoot() { return root; }
    /**
     * Gets the controller associated with the loaded FXML view.
     * @return The controller.
     */
    public T getController() { return controller; }
}