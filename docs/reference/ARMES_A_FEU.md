# Armes à feu du refuge

Installés dans Studio, sans publication :

- **Mitrailleuse de barrage** :54000pièces/niveau35,28corps/42tête,portée160,intervalle.12,48balles,recharge3.8s. Boîtier/couvercle/levier mobiles et soutien/recharge dédiés. [Preuves et limites](MITRAILLEUSE.md).

- **Fusil du guetteur** : 32 000 pièces, niveau 28, dégâts corps 140 / tête 210, portée 260 studs, intervalle 1,05 s, chargeur 6, recharge 3,1 s. Arme à verrou, dioptre sans zoom, bipied décoratif, chargeur et culasse mobiles. [Preuves et limites](GUETTEUR.md).

- **Carabine des cendres** : 18 000 pièces, niveau 22, dégâts corps 38 / tête 57, portée 175 studs, cadence 0,24 s, chargeur 18, rechargement 2,4 s. Crosse, garde-main ventilé, poignée avant et viseur décoratif ; pas de zoom secondaire. Chargeur et levier de culasse mobiles dans les deux vues, pose de soutien à deux mains, recul et recharge dédiés. Sons réutilisés avec timbres distincts, claquement de culasse et trois étapes de recharge. [Progression et preuves du lot](PROGRESSION_ARMES.md).

- **Pistolet du refuge** : prix 1 400 pièces, niveau 3, dégâts 24, portée 150 studs, cadence 0,28 s, chargeur 12, rechargement 1,6 s. Réserve illimitée pour maintenir le rythme, chargeur limité.

- **Mitraillette du récupérateur (SMG)** : prix 4 200 pièces, niveau 7, dégâts 14, portée 105 studs, cadence 0,11 s, chargeur 24, rechargement 2,1 s. Teinte turquoise, modèle détaillé avec canon, garde-main, évents et crosse.

- **Revolver du pisteur** : prix 6 800 pièces, niveau 12, dégâts 72, portée 180 studs, cadence 0,72 s, barillet 6 coups, rechargement 2,6 s. Alternative précise et puissante, plus lente que la SMG. Modèle métal/bois avec barillet à six amorces et chien, aperçu 3D dans l'armurerie et modèle porté.

Le revolver possède une courbe de recul et une recharge distinctes. WeaponMotion.PartPose ouvre le barillet, le fait tourner et le referme dans les deux vues ; le modèle porté utilise les mécanismes décrits dans ANIMATIONS_ARMES.md. Les sons réutilisent l'asset métal existant avec une détonation plus grave et trois étapes mécaniques distinctes : aucun nouvel enregistrement sonore n'est ajouté. Les poses de frappe et de recharge sont atténuées avec ReducedMotion ; la géométrie fonctionnelle du barillet reste lisible.

## Tirs de tête — dernière preuve

Les armes à feu font désormais ×1,5 sur les parties Head/VisualHead canoniques déterminées par le raycast serveur : pistolet 36, SMG 21, revolver 108, fusil 30 par plomb (210 au maximum). Corps inchangé. Un tir mixte du fusil additionne chaque impact tête/corps avant un seul dégât/feedback par cible. Aucun bonus de pièces/XP spécifique aux tirs de tête ; portée, cadence, recharges et récompenses ordinaires conservées.

Voir docs/reference/TIRS_A_LA_TETE.md et studio/qa/headshots-result.json : 30 contrôles dédiés + 33 régressions armes précédentes + 30 régressions corps du fusil, tous passés. Douze vraies têtes de templates visées par le pont client, plus une vraie mort Civilian à 36 dégâts, +8 pièces/+20 XP une fois. Montants/indicateurs falsifiés client ignorés ; murs et zones bloquent encore les tirs. Les anciennes preuves ci-dessous décrivent les dégâts corps et l'état historique sans critiques.

FistsClient ajoute TETE! et respecte ReducedMotion pour les bulles (pas de rotation/pop/déplacement, quatre traits fixes). Le cinquième argument facultatif PunchHit reste compatible avec les frappes précédentes. Une garde ignore les effets lorsque la vue est trop petite, sans affecter les dégâts. Console finale vide. Aucun rendu final validé : caméra client 1×1 pendant ces tests. Le rappel de l'armurerie a été installé/compilé après les essais de combat ; son adaptation finale reste à vérifier avec les autres pages UI.

## Fusil à pompe des quais — 23 octobre 2026

Prix 11 500 pièces, niveau 16, cinq cartouches, recharge 2,9 s, portée 75 studs, cadence 0,95 s. Sept plombs de 20 dégâts corps chacun (140 au total), ou 30 par tête (210 au total). Dispersion déterministe serveur : centre et six directions en couronne à 4,5°. Chaque plomb est arrêté par la géométrie solide ; les dégâts sont regroupés par zombie avant TakeDamage, attribution et chiffre de dégâts. Une cartouche consommée par tir, quel que soit le nombre de cibles. Les anciennes armes gardent une seule direction. Aucun montant, cible, dispersion ou nombre de plombs accepté du client.

Modèle orange/bois/métal avec crosse, canon long, magasin tubulaire, cartouches latérales et pompe rainurée mobile. Recul, maintien gauche, cycle de pompe et recharge dédiés ; cinq gestes d'insertion puis un clic final. Le remplissage des cinq cartouches reste atomique à la fin, sans insertion partielle fonctionnelle. Modèle porté statique et poses corporelles sur les couches Motor6D/AnimationConstraint existantes ; animations entre plusieurs joueurs non vérifiées. Pompe et poses du fusil atténuées avec ReducedMotion. Le barillet du revolver conserve son débattement fonctionnel précédent.

Un événement ShotFX contient les sept destinations et l'identifiant d'arme figé au tir. Un flash et une détonation par événement ; un son de pompe différé. Asset métal existant réutilisé, sans nouvel enregistrement. Les réglages SFX sont respectés ; les instances ont été observées, sans audition revendiquée. Armurerie : aperçu 3D et description « 7 x 20 degats », achat disponible depuis l'UI loin des stands.

Preuves : studio/qa/shotgun-result.json. 33 régressions des anciennes armes, 30 contrôles fusil à pompe et cinq contrôles sur la mort d'un vrai Civilian (+8 pièces/+20 XP une fois). Vrais Shoot:FireServer par pont client, avec tests de cibles multiples, murs transparents solides, déclencheurs non solides, portée, cadence, recharge/cancellation et zone interdite. L'ancien harnais de vraie mort supposait un chargeur neuf malgré les essais précédents ; corrigé pour mesurer son état réel.

Achat par clic PC : 20 000 → 8 500 pièces, arme équipée. Sampler rendu final : pompe ~0,2198 stud puis retour <0,00001, sept traceurs/un flash/un son par tir, six étapes mécaniques par recharge ; angle de main ~0,657 rad normal / ~0,164 réduit, muet respecté. TIR activé à la souris sur téléphone simulé avec libération temporaire du pointeur, cinq → quatre cartouches. Ne prouve pas un tactile physique.

Correction du lot suivant : le preset sélectionné était iphone_7 ; la recherche par espace ASCII ignorait les noms récents avec une espace insécable. Les mesures ne changent pas, mais ne proviennent pas du preset iPhone 17 Pro.

Captures inspectées sur PC 1447×801 et iPhone 7 simulé 666×374 / 374×666. À moins de 700 px de largeur paysage, les munitions passent à gauche sous statistiques/boosts : position (14,249), taille 170×42 avec les deux boosts ; portrait (180,249). Aucun recouvrement des commandes visibles contrôlées ; le grand cadre invisible du joystick dynamique traverse cette région et le compteur reste non interactif. Les autres pages portrait conservent les limites documentées. Console finale : avertissement interne Roblox Assistant RemoteServiceGate, pas d'erreur de jeu observée. Pas de test multijoueur, persistance de production, matériel tactile/manette, audition ou équilibrage long.

Nouveau module ReplicatedStorage.FirearmBallistics ; huit scripts modifiés sauvegardés dans ServerStorage.BeforeShotgun. Aucun changement de schéma de profil/reçus, aucune réinitialisation. Robux toujours désactivé. QA uniquement Play, jamais scripts de démarrage.

## Preuve précédente — revolver et disposition mobile

studio/qa/revolver-result.json contient 33 contrôles passés via le véritable pont client Firearms, dont les 19 régressions précédentes et 14 contrôles revolver : seuil, fonds, prix/double achat, six balles, modèle distinct, dégâts/cadence, blocage pendant recharge, annulation sans gain, remplissage et poses. Cette suite remplace les anciens comptes ci-dessous.

RevolverPresentation.client.luau a mesuré le modèle réellement rendu : ouverture du barillet ~0,354 stud, retour <0,00002 stud, trois clics mécaniques, recharge complète ; rotation de la main ~1,014 rad contre ~0,254 rad en réduction des mouvements. Achat réellement cliqué dans l'armurerie PC : 10 000 → 3 200 pièces, arme équipée avec six balles. Ces essais ne prouvent ni audition des sons, ni tactile physique, ni multijoueur.

Sur iPhone simulé paysage/portrait, les rectangles munitions/Options/niveau/statut et commandes contrôlées ne se chevauchent plus. Recharge déplacée à gauche de Tir en paysage large. Les ombres des cartes copient désormais leur UIScale. Backup des huit scripts de ce lot et du guide précédent : ServerStorage.BeforeRevolver. Les essais de clic simulé en portrait sur Jouer sont restés sans effet pendant cette passe ; cause à vérifier séparément.

Commandes : R / X manette / bouton tactile RECHARGE ; rechargement automatique à chargeur vide. Le maintien du bouton de tir enchaîne les coups à la cadence autorisée.

## Architecture et fonctionnement

- **Validation serveur (`FirearmsServer`)** : contrôle de l'arme équipée, état de vie, filtre anti-spam (0,9x cooldown), direction non nulle de magnitude normalisée, obstacles bloquants et passage à travers les volumes déclencheurs transparents non-collisionnables (ex. portails du refuge).

- **Attribution des dégâts** : les dégâts zombies créditent le joueur (`LastAttacker`, `LastHitAt`) et déclenchent le feedback `PunchHit`.

- **Refus de mêlée** : `FistsServer` refuse toute attaque au poing ou coup de mêlée tant qu'une arme à feu est équipée.

- **Persistance en session** : le chargeur est conservé entre changements d'arme pendant la vie du joueur ; réinitialisé à la mort.

- **Annulation du rechargement** : changer d'arme pendant un rechargement interrompt la séquence et empêche le remplissage anticipé du chargeur.

## Améliorations audiovisuelles (22 octobre 2026)

1. **Audio différencié (`FirearmsClient`)** :

   - *Pistolet* : coup percutant grave (playback speed ~1.38, volume 0.48), rechargement en 2 temps (éjection, réarmement culasse).

   - *Mitraillette* : détonation vive et rapide (playback speed ~1.95 avec variation aléatoire, volume 0.38), rechargement en 3 clics mécaniques (éjection, introduction chargeur, culasse).

   - *Traceurs et flashs* : adaptés à la signature couleur de chaque arme (ambre/or pour le pistolet, turquoise pour la mitraillette).

2. **Cadrage et pose première personne (`FistsClient`)** :

   - Les armes à feu sont recentrées et relevées (`X: 0.50, Y: -0.66, Z: -1.48`) pour éviter l'occultation par les boutons d'action tactiles en bas à droite sur mobile et centrer les organes de visée.

   - La main gauche (`LeftArm`) adopte une posture de soutien dédiée : maintien sous le garde-main pour la SMG (`X: 0.24, Y: -0.60, Z: -1.52`), et maintien de paume tactique pour le pistolet (`X: 0.36, Y: -0.70, Z: -1.45`), avant d'être animée par `WeaponMotion.Reload` lors des rechargements.

   - Recul différencié à la première personne : recul lourd et impulsion FOV marquée pour le pistolet, jitter rapide et impulsion FOV resserrée pour la mitraillette.

3. **Pénétration des volumes transparents (`FirearmsServer`)** :

   - Le raycast serveur filtre récursivement les volumes déclencheurs non-collisionnables et transparents (ex. `Travel_Factory.Field`), garantissant que les tirs ne sont pas absorbés par des zones de voyage ou d'ambiance.

## Vérifications historiques

L'ancien rapport `studio/qa/firearms-result.json` annonçait 18 contrôles avec un harnais depuis corrigé. Ce total historique n'est pas une preuve actuelle ; utiliser les 33 contrôles de revolver-result.json, exécutés via le pont client. L'ancien périmètre annoncé était :

- Verrouillage niveau 1 (pistolet) et niveau 3 (SMG)

- Achat et débits exacts (1400 et 4200 pièces)

- Rejet des doubles achats sans second débit

- Munitions initiales exactes (12 et 24)

- Rejet des vecteurs de tir invalides

- Consommation unitaire par tir

- Limitation anti-spam des rafales simultanées

- Blocage physique par les murs solides

- Traversée des volumes transparents

- Dégâts effectifs et identification du tueur

- Rejet absolu des attaques de mêlée pendant l'équipement d'arme à feu

- Blocage du tir pendant le rechargement

- Annulation sans remplissage lors d'un switch d'arme

- Rechargement complet et rétablissement du chargeur

Backup de sécurité : `ServerStorage.BeforeFirearmsPolish`.

Play arrêté après essais, aucune sauvegarde de données de production.

