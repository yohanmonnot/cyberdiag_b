package edu.cyclonicforce.fr.ui.lib.util.argParser;

/**
 * A class representing a setting argument with category, name, and actAs properties.
 */
public class Argument {
    /**
     * The category of the setting (short or long argument).
     */
    private ArgCategory category;
    /**
     * The name of the setting.
     */
    private String name;
    /**
     * The actAs value of the setting.
     */
    private Param actAs;

    /**
     * Constructor for Argument class.
     * @param category Category of the argument (short or long)
     * @param name Name of the argument
     * @param actAs ActAs value of the argument
     */
    public Argument(ArgCategory category, String name, Param actAs) {
        if (category == null || name == null || actAs == null) {
            throw new IllegalArgumentException("Arguments cannot be null");
        }
        this.category = category;
        this.name = name;
        this.actAs = actAs;
    }

    /**
     * Returns the category of the argument.
     * @return the category of the argument
     */
    public ArgCategory getCategory() {
        return category;
    }
    /**
     * Sets the category of the argument.
     * @param category the new category of the argument
     * @throws IllegalArgumentException if category is null
     */
    public void setCategory(ArgCategory category) {
        if (category == null) {
            throw new IllegalArgumentException("Category cannot be null");
        }
        this.category = category;
    }

    /**
     * Returns the name of the argument.
     * @return the name of the argument
     */
    public String getName() {
        return name;
    }
    /**
     * Sets the name of the argument.
     * @param name the new name of the argument
     * @throws IllegalArgumentException if name is null
     */
    public void setName(String name) {
        if (name == null) {
            throw new IllegalArgumentException("Name cannot be null");
        }
        this.name = name;
    }

    /**
     * Returns the actAs value of the argument.
     * @return the actAs value of the argument
     */
    public Param getActAs() {
        return actAs;
    }
    /**
     * Sets the actAs value of the argument.
     * @param actAs the new actAs value of the argument
     * @throws IllegalArgumentException if actAs is null
     */
    public void setActAs(Param actAs) {
        if (actAs == null) {
            throw new IllegalArgumentException("ActAs cannot be null");
        }
        this.actAs = actAs;
    }
}
