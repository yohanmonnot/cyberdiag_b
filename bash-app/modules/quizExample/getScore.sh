#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QUIZ_FILE="$DIR/quiz.json"
ANSWERS_JSON="$1"

# Vérification input
if [ -z "$ANSWERS_JSON" ] || [ "$(echo "$ANSWERS_JSON" | jq 'type')" != '"array"' ]; then
    echo '{"exitCode":1,"error":"Invalid input: Expected a JSON array","score":0,"recommandation":""}'
    exit 1
fi

RESULT=$(jq -r --argjson answers "$ANSWERS_JSON" '
  . as $quiz |
  ([range(0; $quiz | length)]) as $required_indexes |
  ([$answers[].index]) as $provided_indexes |

  ($required_indexes - $provided_indexes) as $missing |

  if ($missing | length > 0) then
    {
      exitCode: 1,
      error: "Index de questions manquants : \($missing | join(", "))",
      score: 0,
      recommandation: ""
    }
  else
    [
      $answers[] | . as $ans |
      ($quiz[] | select(.index == $ans.index)) as $q |

      if $q.type == "choice" then
        ($q.options[] | select(.index == ($ans.value | tonumber)))
      else
        ($q.options[] | select(
          (.conditions // []) |
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
      score: (((map(.score) | add) / length * 100 | round) / 100),
      recommandation: (map("- " + .question + " : " + .feedback) | join("\n"))
    }
  end
' "$QUIZ_FILE")

echo "$RESULT"