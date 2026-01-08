package edu.cyclonicforce.fr.ui.metier;

import java.util.HashMap;
import java.util.Map;

public class Diagnostic {
    private String title;
    private String version;
    private String author;
    private String description;
    private String level;
    private Map<String, String[]> steps;

    public Diagnostic(String title, String version, String author, String description, String level, Map<String, String[]> steps) {
        this.title = title;
        this.version = version;
        this.author = author;
        this.description = description;
        this.level = level;
        this.steps = steps;
    }

    public String getTitle() {
        return title;
    }

    public String getVersion() {
        return version;
    }

    public String getAuthor() {
        return author;
    }

    public String getDescription() {
        return description;
    }

    public String getLevel() {
        return level;
    }

    public Map<String, String[]> getSteps() {
        Map<String, String[]> stepsCopy = new HashMap<>();
        for (Map.Entry<String, String[]> entry : steps.entrySet()) {
            stepsCopy.put(entry.getKey(), entry.getValue().clone());
        }
        return stepsCopy;
    }

    public void setSteps(Map<String, String[]> steps) {
        this.steps = new HashMap<>();
        for (Map.Entry<String, String[]> entry : steps.entrySet()) {
            this.steps.put(entry.getKey(), entry.getValue().clone());
        }
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public void setVersion(String version) {
        this.version = version;
    }

    public void setAuthor(String author) {
        this.author = author;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public void setLevel(String level) {
        this.level = level;
    }
}
