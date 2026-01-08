package edu.cyclonicforce.fr.ui.view;

import edu.cyclonicforce.fr.ui.controller.AppController;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;

import java.io.IOException;
import java.lang.reflect.InvocationTargetException;

public class ViewLoader<T> {
    private T controller;
    private Parent root;

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

    public Parent getRoot() { return root; }
    public T getController() { return controller; }
}