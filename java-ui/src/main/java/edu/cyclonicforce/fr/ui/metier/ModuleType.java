package edu.cyclonicforce.fr.ui.metier;

public enum ModuleType {
    TOOL,
    INTERFACE,
    DIAGNOSTIC,
    REPORTING,
    QUIZ;

    private final String type;

    ModuleType() {
        this.type = this.name().toLowerCase();
    }

    public String getTypeStr() {
        return type;
    }
}
