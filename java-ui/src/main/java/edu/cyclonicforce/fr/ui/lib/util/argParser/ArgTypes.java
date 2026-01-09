package edu.cyclonicforce.fr.ui.lib.util.argParser;

/**
 * A collection of predefined argument type strategies for parsing command-line arguments.
 */
public class ArgTypes {
    /**
     * String argument type strategy.
     */
    public static final ArgTypeStrategy<String> STRING = new ArgTypeStrategy<>() {
        @Override public String parse(String value) { return value; }
        @Override public String getTypeName() { return "String"; }
    };

    /**
     * Integer argument type strategy.
     */
    public static final ArgTypeStrategy<Integer> INTEGER = new ArgTypeStrategy<>() {
        @Override
        public Integer parse(String value) {
            try {
                return Integer.parseInt(value);
            } catch (Exception e) {
                throw new ArgParseException("An error occurred while parsing Integer argument: " + e.getMessage(), e);
            }
        }
        @Override public String getTypeName() { return "Integer"; }
    };

    /**
     * Float argument type strategy.
     */
    public static final ArgTypeStrategy<Float> FLOAT = new ArgTypeStrategy<>() {
        @Override
        public Float parse(String value) {
            try {
                return Float.parseFloat(value);
            } catch (Exception e) {
                throw new ArgParseException("An error occurred while parsing Float argument: " + e.getMessage(), e);
            }
        }
        @Override public String getTypeName() { return "Float (decimal)"; }
    };

    /**
     * Double argument type strategy.
     */
    public static final ArgTypeStrategy<Double> DOUBLE = new ArgTypeStrategy<>() {
        @Override
        public Double parse(String value) {
            try {
                return Double.parseDouble(value);
            } catch (Exception e) {
                throw new ArgParseException("An error occurred while parsing Double argument: " + e.getMessage(), e);
            }
        }
        @Override public String getTypeName() { return "Double (decimal)"; }
    };

    /**
     * Boolean argument type strategy.
     */
    public static final ArgTypeStrategy<Boolean> BOOLEAN = new ArgTypeStrategy<>() {
        @Override public Boolean parse(String value) { return Boolean.parseBoolean(value); }
        @Override public String getTypeName() { return "Boolean"; }
    };

    /**
     * Flag argument type strategy (no value).
     */
    public static final ArgTypeStrategy<Void> FLAG = new ArgTypeStrategy<>() {
        @Override public Void parse(String value) { return null; }
        @Override public String getTypeName() { return "Flag"; }
    };
}