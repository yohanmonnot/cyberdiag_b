#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QUIZ_FILE="$DIR/quiz.json"
ANSWERS_JSON="$1"

# Vérification basique de l'input
if [ -z "$ANSWERS_JSON" ] || [ "$(echo "$ANSWERS_JSON" | jq 'type')" != '"array"' ]; then
    echo "{\"exitCode\": 1, \"error\": \"Invalid input: Expected a JSON array\", \"score\": 0, \"recommandation\": \"\"}"
    exit 1
fi

# Traitement avec jq
RESULT=$(jq -r --argjson answers "$ANSWERS_JSON" '
  . as $quiz |
  ([range(0; $quiz | length)]) as $required_indexes |
  ([$answers[].index]) as $provided_indexes |

  # 1. Vérification des index manquants
  ($required_indexes - $provided_indexes) as $missing |

  if ($missing | length > 0) then
    {
      exitCode: 1,
      error: "Index de questions manquants : \($missing | join(", "))",
      score: 0,
      recommandation: ""
    }
  else
    # 2. Calcul du score et des feedbacks
    [
      $answers[] | . as $ans |
      ($quiz | .[] | select(.index == $ans.index)) as $q |

      if $q.type == "choice" then
        # On cherche l option dont l index correspond à la value envoyée
        ($q.options[] | select(.index == ($ans.value | tonumber)))
      else
        # Type number : on vérifie que TOUTES les conditions d une option sont vraies
        ($q.options[] | select(
          . as $opt |
          (.condition // .conditions // []) |
          all(.[] ;
            if .operator == ">=" then ($ans.value >= .value)
            elif .operator == "<" then ($ans.value < .value)
            elif .operator == "==" then ($ans.value == .value)
            else false end
          )
        ))
      end |
      {score: .score, feedback: .feedback, question: $q.question}
    ] |
    {
      exitCode: 0,
      error: "",
      score: (((map(.score) | add / length) * 100 | round) / 100),
      recommandation: (map(.question + ": " + .feedback) | join(", "))
    }
  end
' "$QUIZ_FILE")

echo "$RESULT"