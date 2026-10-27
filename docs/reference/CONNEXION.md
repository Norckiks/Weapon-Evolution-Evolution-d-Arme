# Calendrier de connexion

Un cadeau à récupérer manuellement par jour UTC dans **Cadeaux & paliers**. Les sept étapes sont successives, sans obligation de revenir des jours consécutifs. Une absence ne remet rien à zéro et ne donne pas de cadeaux rétroactifs. Après le septième, le cycle recommence au premier le prochain jour disponible.

| Cadeau | Récompense |
| --- | --- |
| 1 | 200 pièces |
| 2 | XP ×2 pendant 10 minutes |
| 3 | 500 pièces |
| 4 | Pièces ×2 pendant 10 minutes |
| 5 | 1 000 pièces |
| 6 | 1 000 XP |
| 7 | Un Buddy permanent |

Les boosts prolongent une durée déjà active. Pièces/XP fixes ne sont pas multipliés par un pet ou un boost. Le Buddy utilise le modèle/bonus existants et s’équipe seulement si aucun pet n’est équipé ; les copies s’ajoutent à l’inventaire. Ni paiement ni récompense aléatoire.

`Meta.Login.Step` vaut 0..6 (cadeaux déjà récupérés dans ce cycle), `Meta.Login.Day` contient le dernier jour UTC réclamé. Ils restent hors de `Daily`, sont normalisés pour les anciens profils et passent dans le JSON Meta existant. Aucun reçu ou profil n’est effacé. Le transport GameState ajoute Login et LoginReady ; le serveur décide la date et la récompense, le client envoie uniquement ClaimLogin/Daily. Un timestamp futur refuse une nouvelle réclamation.

Contrôles de démarrage, type d’identifiant et fréquence du routeur existant conservés. Portefeuille limité à deux milliards : si la récompense entière ne tient pas, aucun crédit ni avancement. Même principe à 100 000 copies Buddy. Reçu de jour/étape modifié avant l’attribution, sans yield ; erreur d’AddRewards restaure ces deux valeurs. Sauvegarde par le chemin existant, sans nouvelle DataStore ni activation Robux.

UI : première carte de Cadeaux, image adaptée, barre du cycle, bouton RECUPERER/DEMAIN/DEPENSE D’ABORD/INVENTAIRE PLEIN. Après une réclamation, la carte montre le prochain cadeau pour demain. La signature de catalogue inclut Login et LoginReady, avec mises à jour serveur ordinaires au changement UTC. Le compteur Cadeaux ne compte pas ce cadeau quand l’inventaire ou le portefeuille bloque.

## Preuves et limites du 27 octobre

Trois sources comparées et synchronisées Edit : GameplayConfig, EconomyService, GameHub ; backup ServerStorage.BeforeLoginCalendar. Aucun script actif supplémentaire.

`studio/qa/login-calendar-result.json` : 41 assertions serveur passées avec vrais messages client GameAction par LevelRewardsBridge, plus 15 assertions de propriétés UI (Ready/Claimed/Full). Sept récompenses exactes, aucun doublon, faux identifiants, refus avant démarrage, boosts cumulés, capacités pleines/exactes, jours sautés/date future, reset Daily indépendant, JSON/reçus préservés et champs malformés. Harnais LoginCalendar.server et LoginCalendarUI.client uniquement Play SessionStudio. Fixture Meta/statistiques/attributs restaurée puis Stop, console vide lors du contrôle.

Premier essai : une comparaison de tout Meta détectait le compteur de temps qui avance normalement pendant la requête ; remplacée par une comparaison des seuls champs de récompense. Aucun changement produit pour masquer cet échec du harnais. Deux assertions supplémentaires en nouvelle session confirment le badge : absent à portefeuille plein, un cadeau à solde500 (cadeaux de temps masqués dans la fixture). Métadonnées/solde/flags restitués avant Stop.

Pas de reconnexion DataStore, multijoueur, passage réel de minuit, clic natif ou tactile physique. Date simulée dans la fixture en modifiant le dernier jour réclamé, sans modifier l’horloge. Viewport 1×1/RenderStepped0 : pas de preuve visuelle/mobile des nouvelles cartes. Aucune publication ni sauvegarde .rbxl.
