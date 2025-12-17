Documentation – main.sh
Description 
main.sh est un script Bash permettant de vérifier la configuration des paramètres de validation des mots de passe utilisés par les modules PAM (Pluggable Authentication Modules).
Il analyse les fichiers de configuration du système afin de déterminer si les règles de sécurité appliquées aux mots de passe respectent les bonnes pratiques recommandées.

Paramètres vérifiés
Le script contrôle les paramètres suivants :
•	minlen : longueur minimale du mot de passe.
•	dcredit : nombre minimal de chiffres requis.
•	ucredit : nombre minimal de lettres majuscules requises.
•	lcredit : nombre minimal de lettres minuscules requises.
•	ocredit : nombre minimal de caractères spéciaux requis.
•	difok : nombre de caractères différents requis entre l’ancien et le nouveau mot de passe.

Résultat du script
Le script renvoie un objet JSON contenant quatre champs :
{
  "exitCode": "OK" | "WARNING" | "CRITICAL",
  "error": "message d’erreur ou vide",
  "score": 0 à 5,
  "recommendation": "texte de recommandation"
}

Détail des champs :
•	exitCode
o	OK : tous les paramètres sont conformes aux recommandations.
o	WARNING : un ou plusieurs paramètres peuvent être améliorés.
o	CRITICAL : aucune configuration PAM de sécurité détectée ou paramètres essentiels absents.
•	error
o	Contient un message uniquement si aucun fichier de configuration PAM valide n’a été trouvé.
•	score
o	Entier entre 0 et 5, représentant le niveau de conformité global.
•	0 = aucune règle respectée
•	5 = configuration totalement conforme
•	recommendation
o	Indique le niveau de conformité et suggère d’éventuelles améliorations à appliquer.

Détails du comportement
•	Si le nombre de warn_count est supérieur à 0, le statut devient "WARNING".
•	Si le nombre de crit_count est supérieur à 0, le statut devient "CRITICAL".
•	Si aucune alerte n’est détectée, le statut reste "OK".
•	Le score est calculé sur la base du ratio de paramètres valides, puis normalisé sur une échelle de 0 à 5 (entier sans décimale).
•	Le champ error s’affiche uniquement lorsque les fichiers PAM ne sont pas trouvés sur le système.

Utilisation
Pour exécuter le script :
sudo ./main.sh

Tests intégrés
Fonctionnalité : run_self_tests()

La fonction run_self_tests() est intégrée directement au script et permet de vérifier automatiquement les principales fonctions internes du module.
Elle s’exécute uniquement si l’argument --test est passé au script.

Exemple d’exécution
sudo ./main.sh --test

Tests effectués
Test	Description	Objectif
check_numeric – valeur correcte	Vérifie que la fonction check_numeric identifie une valeur conforme.	S’assurer que les comparaisons numériques fonctionnent.
check_numeric – valeur trop faible	Teste le comportement lorsque la valeur réelle est inférieure à la recommandation.	Confirmer la détection d’un avertissement.
get_option_value	Vérifie que la fonction ne provoque pas d’erreur en cas de clé absente.	Garantir la robustesse du script.
Sortie JSON valide	Vérifie que le JSON de sortie est syntaxiquement correct (testé via jq).	S’assurer de la compatibilité machine (parse JSON).

Exemple de résultat attendu
=== Running internal tests for check_password ===

PASS - check_numeric returns ok for valid value
PASS - check_numeric warns on low value
PASS - get_option_value executes without error
PASS - JSON output is valid

Résultat global: 4 tests exécutés | 4 passés | 0 échoués

Tous les tests internes sont passés avec succès.

Interprétation des résultats

PASS : le test s’est exécuté correctement.

FAIL : le test a échoué (la fonction doit être corrigée).

À la fin, un résumé global indique le nombre de tests passés / échoués.

Prérequis
•	Exécution avec les droits administrateur (sudo).
•	Présence d’au moins un des fichiers PAM suivants :
o	/etc/pam.d/common-password (Debian / Ubuntu)
o	/etc/pam.d/system-auth (RHEL / CentOS)
o	/etc/pam.d/password-auth (RHEL / CentOS)

Exemple de sortie JSON
{
  "exitCode": "WARNING",
  "error": "",
  "score": 4,
  "recommendation": "Some password policy improvements are recommended."
}

Notes
•	Le script ne modifie aucune configuration système : il effectue uniquement une analyse.
•	Il peut être utilisé dans le cadre d’un audit de sécurité, d’une supervision ou d’un outil d’évaluation de conformité.
•	Les recommandations reposent sur des valeurs de sécurité recommandées par l’ANSSI pour les systèmes Linux modernes.

