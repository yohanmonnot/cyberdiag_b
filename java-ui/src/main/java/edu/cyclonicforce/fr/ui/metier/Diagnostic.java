package edu.cyclonicforce.fr.ui.metier;

import java.util.HashMap;
import java.util.Map;

/**
 * Class representing a diagnostic with its metadata and steps.
 */
public class Diagnostic {
    /**
     * Title of the diagnostic.
     */
    private String title;
    /**
     * Version of the diagnostic.
     */
    private String version;
    /**
     * Author of the diagnostic.
     */
    private String author;
    /**
     * Description of the diagnostic.
     */
    private String description;
    /**
     * Level of the diagnostic.
     */
    private String level;
    /**
     * Steps of the diagnostic, mapped by step names.
     */
    private Map<String, String[]> steps;

    /**
     * Constructor for Diagnostic.
     * @param title Title of the diagnostic.
     * @param version Version of the diagnostic.
     * @param author Author of the diagnostic.
     * @param description Description of the diagnostic.
     * @param level Level of the diagnostic.
     * @param steps Steps of the diagnostic, mapped by step names.
     */
    public Diagnostic(String title, String version, String author, String description, String level, Map<String, String[]> steps) {
        this.title = title;
        this.version = version;
        this.author = author;
        this.description = description;
        this.level = level;
        this.steps = steps;
    }

    /**
     * Get the title of the diagnostic.
     * @return Title of the diagnostic.
     */
    public String getTitle() {
        return title;
    }

    /**
     * Get the version of the diagnostic.
     * @return Version of the diagnostic.
     */
    public String getVersion() {
        return version;
    }

    /**
     * Get the author of the diagnostic.
     * @return Author of the diagnostic.
     */
    public String getAuthor() {
        return author;
    }

    /**
     * Get the description of the diagnostic.
     * @return Description of the diagnostic.
     */
    public String getDescription() {
        return description;
    }

    /**
     * Get the level of the diagnostic.
     * @return Level of the diagnostic.
     */
    public String getLevel() {
        return level;
    }

    /**
     * Get the steps of the diagnostic.
     * @return Steps of the diagnostic.
     */
    public Map<String, String[]> getSteps() {
        Map<String, String[]> stepsCopy = new HashMap<>();
        for (Map.Entry<String, String[]> entry : steps.entrySet()) {
            stepsCopy.put(entry.getKey(), entry.getValue().clone());
        }
        return stepsCopy;
    }

    /**
     * Set the steps of the diagnostic.
     * @param steps Steps of the diagnostic.
     */
    public void setSteps(Map<String, String[]> steps) {
        this.steps = new HashMap<>();
        for (Map.Entry<String, String[]> entry : steps.entrySet()) {
            this.steps.put(entry.getKey(), entry.getValue().clone());
        }
    }

    /**
     * Set the title of the diagnostic.
     * @param title Title of the diagnostic.
     */
    public void setTitle(String title) {
        this.title = title;
    }

    /**
     * Set the version of the diagnostic.
     * @param version Version of the diagnostic.
     */
    public void setVersion(String version) {
        this.version = version;
    }

    /**
     * Set the author of the diagnostic.
     * @param author Author of the diagnostic.
     */
    public void setAuthor(String author) {
        this.author = author;
    }

    /**
     * Set the description of the diagnostic.
     * @param description Description of the diagnostic.
     */
    public void setDescription(String description) {
        this.description = description;
    }

    /**
     * Set the level of the diagnostic.
     * @param level Level of the diagnostic.
     */
    public void setLevel(String level) {
        this.level = level;
    }
}
