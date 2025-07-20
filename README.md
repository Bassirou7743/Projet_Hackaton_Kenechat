# KenaChat - Architecture Technique

KenaChat est une application mobile de santé vocale conçue pour améliorer l'accès aux soins au Mali grâce à l'intelligence artificielle et aux technologies adaptées au contexte local.

## 📱 Frontend mobile

Développée avec **Flutter**, une technologie multiplateforme, l’application KenaChat offre une interface fluide et réactive sur **Android et iOS**.  
Flutter permet un développement rapide, avec une expérience utilisateur uniforme, essentielle pour toucher un public varié et parfois non initié au numérique.

## ☁️ Backend et base de données

Le backend utilise **Firebase**, plateforme cloud _serverless_ de Google, qui fournit :

- l’**authentification sécurisée** des utilisateurs (Firebase Authentication),
- le **stockage** et la **synchronisation en temps réel** des données via Firestore,
- la gestion des fonctions serverless avec **Firebase Cloud Functions**.

Ce choix facilite la **scalabilité**, la **rapidité de déploiement**, tout en assurant la **sécurité des données médicales**.

## 🧠 Intelligence artificielle (IA)

Le moteur conversationnel de KenaChat repose sur **Gemini**, l’IA avancée de Google capable de comprendre le **langage naturel dans un contexte médical**.

- Traitement des symptômes exprimés par l’utilisateur.
- Pré-diagnostic contextuel.
- Génération de recommandations.

Le modèle est **affiné (fine-tuning)** pour s’adapter aux **spécificités médicales locales**.

## 🗣️ Traitement du langage naturel (NLP) et vocalisation

Pour rendre l’application accessible aux **populations non alphabétisées** ou parlant des **langues locales**, KenaChat intègre :

- l’**API Jelia**, spécialisée dans la **reconnaissance vocale** et la **synthèse vocale** en langues africaines (comme le **bambara**).

Cette technologie permet :
- la compréhension vocale des questions des utilisateurs,
- la restitution des réponses sous forme **audio**,  
créant ainsi un **dialogue naturel et inclusif**.

## 📍 Géolocalisation et cartographie

La navigation vers les centres de santé se fait via l’**API Google Maps** :

- localisation précise des établissements,
- affichage sur carte,
- optimisation des itinéraires.

Cette fonctionnalité est **essentielle pour l’orientation rapide des patients**.
