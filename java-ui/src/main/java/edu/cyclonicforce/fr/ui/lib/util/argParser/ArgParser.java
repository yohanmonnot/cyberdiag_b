package edu.cyclonicforce.fr.ui.lib.util.argParser;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Utility class for parsing command-line arguments.
 */
public class ArgParser {
    /**
     * Private constructor to prevent instantiation.
     */
    private ArgParser() {
        // Private constructor to prevent instantiation
    }

    /**
     * Array of accepted command-line arguments.
     */
    private final static Argument[] ACCEPTED_ARGS = new Argument[] {
            new Argument(ArgCategory.SHORT, "h", Params.HELP),
            new Argument(ArgCategory.LONG, "help", Params.HELP),
            new Argument(ArgCategory.SHORT, "v", Params.VERBOSE),
            new Argument(ArgCategory.LONG, "verbose", Params.VERBOSE),
            new Argument(ArgCategory.SHORT, "d", Params.DEBUG),
            new Argument(ArgCategory.LONG, "debug", Params.DEBUG),
            new Argument(ArgCategory.LONG, "logs-output", Params.LOGS_OUTPUT),
            new Argument(ArgCategory.LONG, "version", Params.VERSION),
            new Argument(ArgCategory.LONG, "show-stack-trace", Params.SHOW_STACKTRACE)
    };

    /**
     * Prefix for long arguments.
     */
    private final static String LONG_PREFIX = "--";
    /**
     * Prefix for short arguments.
     */
    private final static String SHORT_PREFIX = "-";

    /**
     * Displays help information for command-line arguments.
     */
    private static void showHelp() {
        System.out.println("Available command-line arguments:");
        System.out.println("--------------------------------------------------");

        Map<String, List<Argument>> groupedArgs = Arrays.stream(ACCEPTED_ARGS)
                .collect(Collectors.groupingBy(arg -> arg.getActAs().getName()));

        groupedArgs.forEach((actAsName, argsList) -> {
            String aliases = argsList.stream()
                    .map(arg -> {
                        String prefix = arg.getCategory() == ArgCategory.LONG ? LONG_PREFIX : SHORT_PREFIX;
                        return prefix + arg.getName();
                    })
                    .collect(Collectors.joining(", "));

            Argument representative = argsList.get(0);
            Param paramInfo = representative.getActAs();

            String description = paramInfo.description();
            String typeName = paramInfo.getsIsFlag() ? "Flag" : paramInfo.getTypeStrategy().getTypeName();

            System.out.printf("%-20s : %-8s : %s%n", aliases, typeName, description);
        });

        System.out.println("--------------------------------------------------");
    }

    /**
     * Displays the application version.
     */
    private static void showVersion() {
        System.out.println("Java-UI version: 1.0.0");
    }

    /**
     * Parses command-line arguments into a map.
     * @param args Array of command-line arguments.
     * @return Map of parsed arguments.
     */
    public static Map<String, Object> parseArgs(String[] args) {
        Map<String, Object> parsedArgs = new java.util.HashMap<>();

        boolean nextIsValue = false;
        Argument argForNextValue = null;

        for (Argument arg : ACCEPTED_ARGS) {
            if (arg.getActAs().getsIsFlag()) {
                parsedArgs.put(arg.getActAs().getName(), false);
            }
        }

        for (String arg : args) {
            String[] splitArg = arg.split(" ");
            for (String realArg: splitArg) {
                if (realArg.startsWith(LONG_PREFIX)) {
                    String argName = realArg.substring(LONG_PREFIX.length());
                    for (Argument acceptedArg : ACCEPTED_ARGS) {
                        if (acceptedArg.getCategory() == ArgCategory.LONG && acceptedArg.getName().equals(argName)) {
                            if (!acceptedArg.getActAs().getsIsFlag()) {
                                nextIsValue = true;
                                argForNextValue = acceptedArg;
                            } else {
                                parsedArgs.put(acceptedArg.getActAs().getName(), true);
                            }
                        }
                    }
                } else if (realArg.startsWith(SHORT_PREFIX)) {
                    char[] argChars = realArg.substring(SHORT_PREFIX.length()).toCharArray();
                    for (char argChar : argChars) {
                        String argName = String.valueOf(argChar);
                        for (Argument acceptedArg : ACCEPTED_ARGS) {
                            if (acceptedArg.getCategory() == ArgCategory.SHORT && acceptedArg.getName().equals(argName)) {
                                if (!acceptedArg.getActAs().getsIsFlag()) {
                                    nextIsValue = true;
                                    argForNextValue = acceptedArg;
                                } else {
                                    parsedArgs.put(acceptedArg.getActAs().getName(), true);
                                }
                            }
                        }
                    }
                } else if (nextIsValue) {
                    Object parsedValue = argForNextValue.getActAs().getTypeStrategy().parse(realArg);
                    parsedArgs.put(argForNextValue.getActAs().getName(), parsedValue);

                    nextIsValue = false;
                    argForNextValue = null;
                }
            }
        }

        if (parsedArgs.containsKey(Params.HELP.getName()) && (Boolean) parsedArgs.get(Params.HELP.getName())) {
            showHelp();
            System.exit(0);
        }

        if (parsedArgs.containsKey(Params.VERSION.getName()) && (Boolean) parsedArgs.get(Params.VERSION.getName())) {
            showVersion();
            System.exit(0);
        }

        return parsedArgs;
    }
}