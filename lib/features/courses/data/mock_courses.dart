import '../domain/course.dart';
import '../domain/lesson.dart';
import '../domain/quiz.dart';

final List<Course> mockCourses = [
  Course(
    id: 'sec_owasp',
    title: 'Sécurité Informatique & OWASP',
    description: 'Maîtrisez la sécurisation des applications web en comprenant les vulnérabilités du Top 10 OWASP et comment y remédier dans une API NestJS.',
    duration: '3 heures',
    category: 'Sécurité',
    lessons: [
      Lesson(
        id: 'sec_owasp_xss',
        title: 'Les failles Cross-Site Scripting (XSS)',
        content: '''# Les failles Cross-Site Scripting (XSS)

Le **Cross-Site Scripting (XSS)** est une vulnérabilité majeure du web. Elle permet à un attaquant d'injecter des scripts malveillants (généralement du JavaScript) dans des pages consultées par d'autres utilisateurs.

## Les trois principaux types de XSS :

1. **XSS Stocké (Stored XSS)** : Le script malveillant est enregistré de manière permanente sur le serveur (dans une base de données, un forum de discussion, un profil utilisateur, etc.). Chaque fois qu'un utilisateur consulte cette ressource, le script s'exécute automatiquement dans son navigateur.
2. **XSS Réfléchi (Reflected XSS)** : Le script fait partie de la requête HTTP envoyée au serveur (généralement dans un paramètre d'URL ou un champ de recherche) et est renvoyé directement par le serveur dans la page de réponse sans être nettoyé.
3. **XSS basé sur le DOM (DOM-based XSS)** : La vulnérabilité réside entièrement dans le code JavaScript côté client. Le script client lit une source non sécurisée (comme `location.search` ou l'ancre d'URL) et l'écrit de manière dynamique et non filtrée dans le DOM (ex: via `document.write` ou `.innerHTML`).

---

## Quels sont les impacts d'une faille XSS ?
* **Vol de session** : Accès aux cookies de session (ex: `document.cookie`) pour usurper l'identité de la victime.
* **Défacement de site** : Modification visuelle du site web pour y afficher des messages frauduleux.
* **Hameçonnage (Phishing)** : Injection de faux formulaires de connexion pour intercepter des mots de passe.
* **Redirection malveillante** : Envoi de l'utilisateur vers un site infecté.

---

## Comment contrer le XSS ?

* **Échappement des caractères spéciaux (Contextual Encoding)** : Remplacez les caractères à risque (`<`, `>`, `&`, `"`, `'`) par leurs entités HTML équivalentes (`&lt;`, `&gt;`, `&amp;`, etc.) avant de les afficher.
* **Content Security Policy (CSP)** : Configurez des règles via des en-têtes HTTP pour restreindre les sources depuis lesquelles les scripts peuvent être chargés et exécutés (ex: bloquer les scripts en ligne ou *inline*).
* **Marquer les cookies sensibles comme HttpOnly** : Cela empêche le JavaScript d'accéder au cookie, bloquant ainsi le vol de session automatisé par XSS.''',
      ),
      Lesson(
        id: 'sec_owasp_sqli',
        title: "L'injection SQL (SQLi)",
        content: '''# L'injection SQL (SQLi)

L'**injection SQL** est l'une des vulnérabilités les plus anciennes et les plus dévastatrices. Elle se produit lorsqu'une application transmet des entrées utilisateur non vérifiées directement à une base de données sous forme de requête SQL dynamique.

## Exemple d'injection SQL classique

Imaginez un formulaire de connexion où la requête SQL est générée par concaténation de chaînes de caractères :
```sql
SELECT * FROM users WHERE email = 'email_saisi' AND password = 'mot_de_passe_saisi';
```

Si un attaquant saisit la valeur suivante dans le champ email :
`admin@example.com' OR '1'='1`

La requête SQL finale exécutée par le serveur devient :
```sql
SELECT * FROM users WHERE email = 'admin@example.com' OR '1'='1' AND password = '...';
```

Puisque la condition `'1'='1'` est toujours vraie, la requête renverra les informations de l'administrateur, contournant entièrement le contrôle du mot de passe !

---

## Solutions de sécurisation incontournables :

1. **Utiliser des Requêtes Paramétrées (Prepared Statements)** : C'est la méthode de défense la plus efficace. Les requêtes préparées forcent la base de données à compiler le code SQL d'un côté, et à traiter l'entrée utilisateur comme un simple paramètre (valeur littérale), empêchant l'entrée utilisateur d'altérer la logique de la requête.
2. **Utiliser un ORM (Object-Relational Mapping)** : Les ORMs modernes (comme Prisma, TypeORM, Hibernate) utilisent par défaut des requêtes paramétrées sous le capot.
3. **Appliquer le principe du moindre privilège** : Assurez-vous que le compte de connexion utilisé par l'application pour interagir avec la base de données possède uniquement les privilèges stricts nécessaires (ex: lecture/écriture sur des tables cibles, mais pas de droits de suppression de table ou d'administration).''',
      ),
      Lesson(
        id: 'sec_owasp_nestjs',
        title: 'Sécurisation des API NestJS',
        content: '''# Sécurisation des API NestJS

**NestJS** est un framework Node.js moderne très populaire pour concevoir des APIs. Cependant, il requiert des configurations spécifiques pour assurer une sécurité de niveau entreprise.

## 1. Validation stricte avec ValidationPipe et DTOs
Utilisez le `ValidationPipe` globalement pour intercepter et rejeter toute entrée mal formée avant qu'elle n'atteigne vos contrôleurs.

Installez d'abord les packages requis :
```bash
npm install --save class-validator class-transformer
```

Puis configurez le pipe globalement dans `main.ts` :
```typescript
// main.ts
app.useGlobalPipes(
  new ValidationPipe({
    whitelist: true, // Supprime automatiquement les propriétés non définies dans le DTO
    forbidNonWhitelisted: true, // Renvoie une erreur si des données inconnues sont fournies
    transform: true, // Convertit automatiquement les types (ex: string en number)
  }),
);
```

---

## 2. Intégrer Helmet pour configurer les en-têtes HTTP
`Helmet` est un middleware qui protège votre application en configurant intelligemment divers en-têtes HTTP (anti-clickjacking, renforcement CSP, restriction du MIME sniffing).
```typescript
import helmet from 'helmet';
app.use(helmet());
```

---

## 3. Limiter le débit (Rate Limiting) avec `@nestjs/throttler`
Pour éviter les attaques par force brute ou les surcharges, implémentez un limitateur de débit :
```typescript
// app.module.ts
@Module({
  imports: [
    ThrottlerModule.forRoot([{
      ttl: 60000, // Fenêtre de temps de 1 minute (60s)
      limit: 10,  // Max 10 requêtes par IP dans cette fenêtre
    }]),
  ],
})
export class AppModule {}
```
Vous pouvez ensuite appliquer le `ThrottlerGuard` globalement ou sur des routes sensibles comme `/auth/login`.''',
      ),
    ],
    quiz: Quiz(
      id: 'quiz_sec_owasp',
      title: 'Quiz Sécurité Web & OWASP',
      questions: [
        Question(
          id: 'q_sec_1',
          questionText: 'Quel type de faille XSS stocke de façon permanente le script malveillant sur le serveur (base de données, fichiers, etc.) ?',
          options: [
            'XSS Réfléchi',
            'XSS Stocké',
            'XSS basé sur le DOM',
            'Injection SQL'
          ],
          correctOptionIndex: 1,
          explanation: 'Le XSS stocké (Stored XSS) sauvegarde le script malveillant de manière durable sur le serveur. Il s\'exécute ensuite pour tout visiteur chargeant la page contenant ces données.',
        ),
        Question(
          id: 'q_sec_2',
          questionText: 'Quel mécanisme de défense est le plus efficace pour éliminer définitivement les risques d\'injections SQL ?',
          options: [
            'L\'utilisation de requêtes paramétrées (Prepared Statements)',
            'Le chiffrement des mots de passe en base de données',
            'Le masquage du code source de l\'application',
            'L\'utilisation de cookies sécurisés (Secure)'
          ],
          correctOptionIndex: 0,
          explanation: 'Les requêtes préparées séparent strictement les instructions SQL des données fournies par l\'utilisateur. Ainsi, la base de données ne peut jamais interpréter l\'entrée comme une instruction SQL.',
        ),
        Question(
          id: 'q_sec_3',
          questionText: 'Dans NestJS, à quoi sert l\'option "whitelist: true" configurée sur un ValidationPipe ?',
          options: [
            'À autoriser uniquement les requêtes provenant de domaines spécifiques',
            'À nettoyer et supprimer automatiquement les propriétés non définies dans le DTO cible',
            'À chiffrer les requêtes entrantes',
            'À bloquer les attaques par déni de service (DDoS)'
          ],
          correctOptionIndex: 1,
          explanation: 'L\'option "whitelist: true" filtre les objets d\'entrée et supprime automatiquement toutes les propriétés qui n\'ont pas de décorateurs de validation dans le DTO, empêchant l\'injection de propriétés indésirables.',
        ),
      ],
    ),
  ),
  Course(
    id: 'flutter_dev',
    title: "Développement d'Applications avec Flutter",
    description: "Apprenez à concevoir des applications mobiles modernes et performantes en maîtrisant l'architecture des widgets et la gestion d'état avancée avec Riverpod.",
    duration: '4 heures',
    category: 'Mobile',
    lessons: [
      Lesson(
        id: 'flutter_dev_widgets',
        title: 'Introduction aux Widgets',
        content: '''# Introduction aux Widgets Flutter

En Flutter, **tout est Widget**. L'interface utilisateur est construite par composition de petits blocs de construction imbriqués, formant ce qu'on appelle l'arbre des widgets (*Widget Tree*).

## StatelessWidget vs StatefulWidget

1. **StatelessWidget (Widget sans état)** :
   * Utilisé pour du contenu visuel statique ou dont les données ne changent pas de manière autonome après la création.
   * Il se reconstruit uniquement lorsque ses paramètres d'entrée changent.
   * Exemple : `Text`, `Icon`, `ElevatedButton` simple.

2. **StatefulWidget (Widget avec état)** :
   * Utilisé pour les parties de l'interface qui doivent se mettre à jour dynamiquement au cours du temps (interactions, requêtes réseau, minuterie).
   * Il est composé de deux classes : la classe dérivée de `StatefulWidget` et la classe `State` qui stocke les données mutables.
   * La méthode `setState(() { ... })` est appelée pour informer le framework de redessiner l'UI avec les nouvelles données.

---

## Le BuildContext : Clé de voûte de l'arbre
Le `BuildContext` est passé en paramètre à chaque méthode `build`. Il représente l'emplacement exact d'un widget dans l'arbre global de l'application. 
Grâce au contexte, un widget peut retrouver des ancêtres dans l'arbre pour accéder au thème (`Theme.of(context)`), aux médias (`MediaQuery.of(context)`) ou pour naviguer (`Navigator.of(context)`).

---

## Optimisation de base
* **Utilisation de `const`** : Déclarez vos widgets constructeurs comme `const` chaque fois que possible. Cela permet à Flutter de réutiliser le même objet en mémoire au lieu de le reconstruire inutilement.
* **Granularité** : Découpez vos interfaces complexes en sous-widgets spécialisés plutôt que d'écrire une seule méthode `build` immense.''',
      ),
      Lesson(
        id: 'flutter_dev_riverpod',
        title: "Gestion d'état avec Riverpod",
        content: '''# Gestion d'état avec Riverpod

La gestion d'état est l'un des aspects les plus critiques d'une application Flutter. **Riverpod** est un framework de gestion d'état moderne, puissant, typé, et indépendant de l'arbre des widgets pour une testabilité maximale.

## Les avantages majeurs de Riverpod :
* **Détection des erreurs à la compilation** : Contrairement au package `Provider` historique, Riverpod ne produit pas d'erreurs d'exécution de type `ProviderNotFoundException`.
* **Indépendant du BuildContext** : L'état peut être lu n'importe où, même dans la logique métier pure sans contexte UI.
* **Facile à tester** : Permet de mocker facilement n'importe quel fournisseur de données sans configurer de mocks de widgets complexes.

---

## Types de Providers courants :

| Type de Provider | Cas d'utilisation typique |
| :--- | :--- |
| **Provider** | Lecture seule pure, valeurs constantes, clients API, configurations. |
| **StateProvider** | État simple et atomique (un booléen, un filtre actif, un index d'onglet). |
| **FutureProvider** | Appels réseau asynchrones uniques (ex: récupérer un profil utilisateur). |
| **StreamProvider** | Flux de données en temps réel (ex: écouter des messages Firebase, des sockets). |

---

## Utilisation en pratique : Le ConsumerWidget
Pour lire les providers dans vos widgets, héritez de `ConsumerWidget` à la place de `StatelessWidget`. La méthode `build` reçoit alors un paramètre additionnel appelé `WidgetRef ref` :
```dart
class CounterView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch écoute les modifications et reconstruit l'UI si l'état change
    final counter = ref.watch(counterProvider);
    
    return Text('Compteur : \$counter');
  }
}
```''',
      ),
      Lesson(
        id: 'flutter_dev_async_state',
        title: 'StateNotifier & AsyncNotifier',
        content: '''# StateNotifier et AsyncNotifier dans Riverpod

Pour séparer proprement la logique métier de l'interface utilisateur, il est conseillé de centraliser les modifications d'états complexes dans des contrôleurs dédiés.

## StateNotifier
*Historique mais toujours largement utilisé*, `StateNotifier` encapsule un état unique et expose des méthodes pour le modifier :
```dart
class TodoNotifier extends StateNotifier<List<Todo>> {
  TodoNotifier() : super([]); // État initial vide

  void addTodo(Todo newTodo) {
    state = [...state, newTodo]; // Remplacement total de l'état (immuabilité)
  }
}
```

---

## AsyncNotifier (Recommandé dans Riverpod 2.0+)
Pour les flux de données asynchrones qui peuvent subir des mutations complexes, `AsyncNotifier` est la solution moderne par excellence. Elle permet d'initialiser et de mettre à jour des états asynchrones de façon très propre.

Exemple d'AsyncNotifier :
```dart
class UserProfileNotifier extends AutoDisposeAsyncNotifier<UserProfile> {
  @override
  Future<UserProfile> build() async {
    // Charge l'état initial de manière asynchrone
    return ref.read(apiClientProvider).fetchProfile();
  }

  Future<void> updateBio(String newBio) async {
    state = const AsyncLoading(); // Affiche le chargement à l'UI
    state = await AsyncValue.guard(() async {
      final updatedProfile = await ref.read(apiClientProvider).updateBio(newBio);
      return updatedProfile;
    });
  }
}
```
L'utilisation de `AsyncValue.guard` capture automatiquement les erreurs et met à jour l'état sous forme de `AsyncError` ou `AsyncData` de façon sécurisée.''',
      ),
    ],
    quiz: Quiz(
      id: 'quiz_flutter_dev',
      title: 'Quiz Flutter & Riverpod',
      questions: [
        Question(
          id: 'q_flut_1',
          questionText: 'Quelle méthode d\'un State de StatefulWidget déclenche la reconstruction visuelle du widget ?',
          options: [
            'initState()',
            'build()',
            'setState()',
            'dispose()'
          ],
          correctOptionIndex: 2,
          explanation: 'La méthode `setState(() {})` notifie le framework que l\'état interne a changé et planifie la reconstruction du widget.',
        ),
        Question(
          id: 'q_flut_2',
          questionText: 'Quel type de Provider dans Riverpod est le mieux conçu pour intercepter un appel API asynchrone et retourner un état réactif de chargement/erreur ?',
          options: [
            'Provider',
            'StateProvider',
            'FutureProvider',
            'StreamProvider'
          ],
          correctOptionIndex: 2,
          explanation: 'Le `FutureProvider` convertit automatiquement un Future en un objet `AsyncValue` proposant les états `when(data, error, loading)`.',
        ),
        Question(
          id: 'q_flut_3',
          questionText: 'Dans la méthode build d\'un ConsumerWidget, quelle méthode de WidgetRef doit être privilégiée pour s\'abonner à un provider ?',
          options: [
            'ref.read',
            'ref.watch',
            'ref.listen',
            'ref.refresh'
          ],
          correctOptionIndex: 1,
          explanation: '`ref.watch` doit être utilisé dans la méthode build pour écouter activement les changements du provider et provoquer le rafraîchissement visuel.',
        ),
      ],
    ),
  ),
  Course(
    id: 'db_nosql',
    title: 'Bases de Données & NoSQL',
    description: 'Comprenez le paradigme NoSQL en apprenant à modéliser et optimiser vos requêtes et structures de documents dans Google Cloud Firestore.',
    duration: '2.5 heures',
    category: 'Web',
    lessons: [
      Lesson(
        id: 'db_nosql_firestore',
        title: 'Architecture de Cloud Firestore',
        content: '''# Architecture de Cloud Firestore

**Cloud Firestore** est une base de données NoSQL orientée documents, flexible et hautement évolutive fournie par Google Firebase. Contrairement aux bases relationnelles SQL, les données y sont stockées de façon hiérarchique sous forme de documents JSON-like.

## Les piliers de l'architecture :

1. **Le Document** :
   * C'est l'unité de stockage fondamentale. Un document contient des paires clé-valeur.
   * Il supporte de nombreux types de données (string, number, boolean, maps, arrays, geopoints, références).
   * La taille maximale d'un document est limitée à **1 Mo**.

2. **La Collection** :
   * Une collection est un groupe de documents. Elle ne contient pas directement des données ou d'autres collections, uniquement des documents.
   * Les collections sont créées automatiquement dès que vous y écrivez un premier document.

---

## Caractéristique essentielle : Les requêtes superficielles (Shallow Queries)
Dans Firestore, les requêtes sont superficielles. Cela signifie que lorsque vous demandez un document spécifique, Firestore récupère uniquement les champs de ce document. Il ne récupère jamais les documents des sous-collections imbriquées sous ce document. Cela assure des performances d'API constantes et prévisibles, que vos sous-collections contiennent 10 ou 10 millions de documents !

---

## Synchronisation temps réel
Firestore propose une intégration directe avec des flux de données (Websockets sous le capot). Grâce aux écouteurs de instantanés (`snapshots`), votre application mobile ou web est immédiatement notifiée et mise à jour dès qu'une valeur change en base de données.''',
      ),
      Lesson(
        id: 'db_nosql_modeling',
        title: 'Modélisation de données NoSQL',
        content: '''# Modélisation NoSQL : Dénormalisation & Structures

La modélisation de données en NoSQL diffère radicalement des bases SQL. Au lieu de normaliser (découper les données pour éviter la redondance) et d'utiliser des jointures (`JOIN`), le NoSQL s'appuie sur la structure idéale requise par l'interface utilisateur pour optimiser les performances de lecture.

## Les 3 structures majeures pour modéliser une relation 1-à-N :

1. **Le document imbriqué (Map / Array)** :
   * Les données liées sont stockées directement à l'intérieur du document parent (ex: une liste d'étiquettes dans un document cours).
   * *Avantage* : Lecture ultra-rapide en un seul appel de document.
   * *Limite* : Attention à la limite de 1 Mo par document.

2. **La sous-collection** :
   * Les documents enfants sont créés dans une sous-collection du document parent (ex: `/courses/course_1/lessons/lesson_a`).
   * *Avantage* : Extensible à l'infini (aucun risque de dépasser la limite de 1 Mo).
   * *Limite* : Nécessite des requêtes supplémentaires pour récupérer la liste.

3. **La collection racine avec référence (Id de liaison)** :
   * Les entités sont stockées séparément à la racine de la base (ex: `/orders` et `/users`), les commandes stockant l'ID de l'utilisateur.
   * *Avantage* : Données indépendantes et faciles à modifier globalement.

---

## Dénormalisation : Le secret de la rapidité
En NoSQL, il est fréquent de dupliquer volontairement une donnée (ex: écrire le nom d'un auteur d'article à la fois dans son profil utilisateur et dans chaque article rédigé). Cela accélère drastiquement les lectures, au détriment de la complexité d'écriture (lorsque l'auteur change de nom, il faut mettre à jour tous ses articles).''',
      ),
      Lesson(
        id: 'db_nosql_queries',
        title: 'Optimisation des requêtes Firestore',
        content: '''# Optimisation et Indexation sur Firestore

Dans Cloud Firestore, toutes les requêtes sont indexées par défaut. Cela signifie que la vitesse de recherche dépend exclusivement de la taille du jeu de données retourné, et **non** du nombre total de documents stockés dans la base de données.

## Types d'index :

* **Index simples** : Firestore crée automatiquement un index simple pour chaque champ présent dans vos documents.
* **Index composites** : Requis lorsque vous combinez plusieurs opérations complexes, par exemple filtrer sur un champ avec une inégalité (`score > 100`) et faire un tri sur un autre champ (`orderBy('date')`), ou faire un filtre d'égalité sur plusieurs champs en même temps.

---

## Pratiques clés pour réduire vos coûts de lecture :

1. **Pagination des requêtes** : Utilisez les curseurs de requête (`startAfter`, `startAt`) associés à un `.limit()` pour implémenter un défilement infini ou des pages. Vous ne lirez ainsi que les documents visibles.
2. **Utiliser des filtres ciblés** : Évitez de rapatrier de larges collections si vous n'avez besoin que d'un sous-ensemble.
3. **Le Cache Local** : Configurez Firestore pour utiliser le cache hors-ligne. Si les données n'ont pas changé sur le serveur, Firestore lit les données localement sur l'appareil, ce qui vous évite des facturations de lectures Firestore superflues !''',
      ),
    ],
    quiz: Quiz(
      id: 'quiz_db_nosql',
      title: 'Quiz Bases de Données NoSQL',
      questions: [
        Question(
          id: 'q_db_1',
          questionText: 'Quelle est la taille maximale autorisée par Google pour un document individuel dans Cloud Firestore ?',
          options: [
            '100 Ko',
            '1 Mo',
            '10 Mo',
            'Illimitée'
          ],
          correctOptionIndex: 1,
          explanation: 'La taille maximale d\'un document dans Firestore est limitée à 1 Mo, ce qui impose de bien réfléchir à la structure d\'imbrication des tableaux volumineux.',
        ),
        Question(
          id: 'q_db_2',
          questionText: 'Que signifie le concept de requêtes superficielles (Shallow Queries) dans Cloud Firestore ?',
          options: [
            'Que les requêtes ne cherchent que les correspondances partielles',
            'Que la lecture d\'un document ne charge pas les documents situés dans ses sous-collections',
            'Que les requêtes ne durent que quelques millisecondes',
            'Que les sous-collections sont automatiquement effacées'
          ],
          correctOptionIndex: 1,
          explanation: 'Les requêtes superficielles garantissent que la récupération d\'un document parent n\'entraîne pas automatiquement la lecture et la facturation de ses sous-collections, optimisant ainsi les performances.',
        ),
        Question(
          id: 'q_db_3',
          questionText: 'Quand est-il obligatoire de créer manuellement un index composite dans Firestore ?',
          options: [
            'Pour effectuer une simple lecture de document par son ID',
            'Pour exécuter des requêtes impliquant des filtres et tris combinés sur plusieurs champs différents',
            'Pour stocker des tableaux complexes',
            'Jamais, Firestore crée tout de manière dynamique sans aucune action requise'
          ],
          correctOptionIndex: 2,
          explanation: 'Bien que Firestore indexe automatiquement les champs uniques, il nécessite un index composite configuré pour résoudre les requêtes combinant filtres complexes (égalité ou inégalité) et tris sur plusieurs champs distincts dans une même requête.',
        ),
      ],
    ),
  ),
];
