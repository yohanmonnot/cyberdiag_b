package edu.cyclonicforce.fr.ui.metier;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

/**
 * Module class
 * @author Célian Touzeau
 * @version 1
 */
public class Module {
    /**
     * Module name
     * Cannot be null or empty
     */
    private String name;
    /**
     * Module version
     * Cannot be null or empty
     */
    private String version;
    /**
     * Module type
     * Cannot be null
     */
    private ModuleType type;
    /**
     * Module description
     */
    private String description;
    /**
     * Module author
     */
    private String author;
    /**
     * Module arguments
     */
    private List<String> args;

    /**
     * Constructor
     * @param name Module name, cannot be null or empty
     * @param version Module version, cannot be null or empty
     * @param type Module type, must be "tool", "interface" or "diagnostic"
     * @param description Module description
     * @param author Module author
     * @param args Module arguments
     * @throws IllegalArgumentException if an argument is invalid
     */
    public Module(String name, String version, String type, String description, String author, List<String> args) {
        setName(name);
        setVersion(version);
        setType(type);
        setDescription(description);
        setAuthor(author);
        setArgs(args);
    }

    /**
     * Constructor
     * @param name Module name, cannot be null or empty
     * @param version Module version, cannot be null or empty
     * @param type Module type
     * @param description Module description
     * @param author Module author
     * @param args Module arguments
     * @throws IllegalArgumentException if an argument is invalid
     */
    public Module(String name, String version, ModuleType type, String description, String author, List<String> args) {
        setName(name);
        setVersion(version);
        setType(type);
        setDescription(description);
        setAuthor(author);
        setArgs(args);
    }

    /**
     * Copy constructor
     * @param other Module to copy
     */
    public Module(Module other) {
        setName(other.getName());
        setVersion(other.getVersion());
        setType(other.getType());
        setDescription(other.getDescription());
        setAuthor(other.getAuthor());
        setArgs(other.getArgs());
    }

    /**
     * Returns the module name
     * @return Module name
     */
    public String getName() {
        return name;
    }
    /**
     * Sets the module name
     * @param name Module name, cannot be null or empty
     * @throws IllegalArgumentException if the name is null or empty
     */
    public void setName(String name) {
        if (name==null || name.isEmpty()) {
            throw new IllegalArgumentException("Module name cannot be null or empty");
        }
        this.name = name;
    }

    /**
     * Returns the module version
     * @return Module version
     */
    public String getVersion() {
        return version;
    }
    /**
     * Sets the module version
     * @param version Module version, cannot be null or empty
     * @throws IllegalArgumentException if the version is null or empty
     */
    public void setVersion(String version) {
        if (version==null || version.isEmpty()) {
            throw new IllegalArgumentException("Module version cannot be null or empty");
        }
        this.version = version;
    }

    /**
     * Returns the module type
     * @return Module type
     */
    public ModuleType getType() {
        return type;
    }

    /**
     * Sets the module type
     * @param type Module type, must be not null
     * @throws IllegalArgumentException if the type is null
     */
    public void setType(ModuleType type) {
        if (type == null) {
            throw new IllegalArgumentException("Module type cannot be null");
        }
        this.type = type;
    }
    /**
     * Sets the module type
     * @param type Module type, must be "tool", "interface" or "diagnostic"
     * @throws IllegalArgumentException if the type is invalid
     */
    public void setType(String type) {
        switch (type) {
            case "tool":
                this.type = ModuleType.TOOL;
                break;
            case "interface":
                this.type = ModuleType.INTERFACE;
                break;
            case "diagnostic":
                this.type = ModuleType.DIAGNOSTIC;
                break;
            default:
                throw new IllegalArgumentException("Invalid module type: " + type);
        }
    }

    /**
     * Returns the module description
     * @return Module description
     */
    public String getDescription() {
        return description;
    }

    /**
     * Sets the module description
     * @param description Module description
     */
    public void setDescription(String description) {
        this.description = Objects.requireNonNullElse(description, "");
    }

    /**
     * Returns the module author
     * @return Module author
     */
    public String getAuthor() {
        return author;
    }
    /**
     * Sets the module author
     * @param author Module author
     */
    public void setAuthor(String author) {
        this.author = Objects.requireNonNullElse(author, "Unknown");
    }

    /**
     * Returns the module arguments
     * @return Module arguments
     */
    public List<String> getArgs() {
        return new ArrayList<>(args);
    }
    /**
     * Sets the module arguments
     * @param args Module arguments
     */
    public void setArgs(List<String> args) {
        this.args = Objects.requireNonNullElse(new ArrayList<String>(args), List.of());
    }

    /**
     * Adds an argument to the module
     * @param arg Argument to add, cannot be null or empty
     * @throws IllegalArgumentException if the argument is null or empty
     */
    public void addArg(String arg) {
        if (this.args == null) {
            this.args = new ArrayList<>();
        }
        if (arg==null || arg.isEmpty()) {
            throw new IllegalArgumentException("Argument cannot be null or empty");
        }
        this.args.add(arg);
    }
    /**
     * Removes an argument from the module
     * @param arg Argument to remove
     */
    public void removeArg(String arg) {
        if (this.args != null) {
            this.args.remove(arg);
        }
    }

    public String toString() {
        StringBuilder argsBuilder = new StringBuilder("[");

        if (args != null && !args.isEmpty()) {
            for (String arg : args) {
                argsBuilder.append(arg).append(", ");
            }
            argsBuilder.setLength(argsBuilder.length() - 2);
        }
        argsBuilder.append("]");

        return "Module{ name='" + name + "', version='" + version + "', type=" + type + ", description='" + description + "', author='" + author + "', util=" + argsBuilder + " }";
    }
}
