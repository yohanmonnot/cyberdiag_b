package edu.cyclonicforce.fr.ui.controller;

/**
 * Interface for the dashboard controller.
 */
public interface DasboardController {
    /**
     * Sets the application controller.
     * @param appController the application controller to set
     */
    void setAppController(AppController appController);

    /**
     * Toggles the size of the dashboard menu.
     * @param menuState the state of the menu (expanded or collapsed)
     */
    void toggleSize(boolean menuState);
}
