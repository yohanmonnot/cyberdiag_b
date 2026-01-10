package edu.cyclonicforce.fr.ui.lib.util.argParser;

/**
 * A collection of predefined command-line parameters for the application.
 */
public class Params {
    /**
     * Parameter to show the help message.
     */
    public static final Param HELP = new Param() {
        @Override
        public String getName() {
            return "help";
        }

        @Override
        public String description() {
            return "Show the help message";
        }

        @Override
        public boolean getsIsFlag() {
            return true;
        }

        @Override
        public ArgTypeStrategy<?> getTypeStrategy() {
            return ArgTypes.FLAG;
        }
    };

    /**
     * Parameter to show the application version.
     */
    public static final Param VERSION = new Param() {
        @Override
        public String getName() {
            return "version";
        }

        @Override
        public String description() {
            return "Show the application version";
        }

        @Override
        public boolean getsIsFlag() {
            return true;
        }

        @Override
        public ArgTypeStrategy<?> getTypeStrategy() {
            return ArgTypes.FLAG;
        }
    };

    /**
     * Parameter to enable verbose mode.
     */
    public static final Param VERBOSE = new Param() {
        @Override
        public String getName() {
            return "verbose";
        }

        @Override
        public String description() {
            return "Enable verbose mode";
        }

        @Override
        public boolean getsIsFlag() {
            return true;
        }

        @Override
        public ArgTypeStrategy<?> getTypeStrategy() {
            return ArgTypes.FLAG;
        }
    };

    /**
     * Parameter to enable debug mode.
     */
    public static final Param DEBUG = new Param() {
        @Override
        public String getName() {
            return "debug";
        }

        @Override
        public String description() {
            return "Enable debug mode";
        }

        @Override
        public boolean getsIsFlag() {
            return true;
        }

        @Override
        public ArgTypeStrategy<?> getTypeStrategy() {
            return ArgTypes.FLAG;
        }
    };

    /**
     * Parameter to specify the logs output directory.
     */
    public static final Param LOGS_OUTPUT = new Param() {
        @Override
        public String getName() {
            return "logs-output";
        }

        @Override
        public String description() {
            return "Specify logs output directory";
        }

        @Override
        public boolean getsIsFlag() {
            return false;
        }

        @Override
        public ArgTypeStrategy<?> getTypeStrategy() {
            return ArgTypes.STRING;
        }
    };

    /**
     * Parameter to show error stack traces.
     */
    public static final Param SHOW_STACKTRACE = new Param() {
        @Override
        public String getName() {
            return "show-stacktrace";
        }

        @Override
        public String description() {
            return "Show error stack traces";
        }

        @Override
        public boolean getsIsFlag() {
            return true;
        }

        @Override
        public ArgTypeStrategy<?> getTypeStrategy() {
            return ArgTypes.FLAG;
        }
    };
}
