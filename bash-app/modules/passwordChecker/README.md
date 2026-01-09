# Documentation – main.sh (Password Policy Checker)

## Description

`main.sh` est un script Bash permettant de **vérifier la configuration de la politique de mots de passe** appliquée par les modules PAM (*Pluggable Authentication Modules*).

Il analyse les fichiers de configuration du système afin de déterminer si les règles de sécurité appliquées aux mots de passe respectent les **bonnes pratiques recommandées**.

Le script est **non intrusif** : il ne modifie aucune configuration système et effectue uniquement une analyse.

---

## Paramètres vérifiés

Le script contrôle les paramètres suivants :

- **minlen** : longueur minimale du mot de passe  
- **dcredit** : nombre minimal de chiffres requis  
- **ucredit** : nombre minimal de lettres majuscules requises  
- **lcredit** : nombre minimal de lettres minuscules requises  
- **ocredit** : nombre minimal de caractères spéciaux requis  
- **difok** : nombre minimal de caractères différents entre l’ancien et le nouveau mot de passe  

Les paramètres sont recherchés dans :
- les fichiers PAM (`pam_pwquality`, `pam_cracklib`, `pam_unix`)
- le fichier `/etc/security/pwquality.conf` (prioritaire s’il existe)

---

## Résultat du script

Le script renvoie **un objet JSON** contenant quatre champs :

```json
{
  "status": "OK" | "WARNING" | "CRITICAL",
  "error": "message d’erreur ou vide",
  "score": 0 à 5,
  "recommendation": "texte de recommandation"
}


