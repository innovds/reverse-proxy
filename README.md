# API Proxy - Configuration Traefik

Ce projet utilise Traefik comme proxy inverse avec une configuration générée dynamiquement à partir de variables d'environnement.

## Structure du projet

```
.
├── compose.yml                    # Configuration Docker Compose
├── update-config.sh               # Script de régénération de config
├── setup-hosts.sh               # Script de configuration des hosts
├── config/
│   ├── generate_config.py        # Générateur de configuration Python
│   ├── traefik.template.yml      # Template Traefik (source)
│   └── traefik.yml               # Configuration Traefik générée
├── .env                          # Variables d'environnement principales
└── .env.local                    # Variables d'environnement locales (optionnel)
```

## Configuration

### 1. Variables d'environnement

Créez vos fichiers de configuration :

**`.env`** (principal) :
```bash
# URLs des services backend
BILLING_URL=https://api.zenyaa.com
```

**`.env.local`** (optionnel, pour surcharger) :
```bash
# Surcharge pour environnement local
BILLING_URL=http://host.docker.internal:7003
```

### 2. Template Traefik

Le fichier `config/traefik.template.yml` contient la configuration Traefik avec des variables à remplacer :

```yaml
http:
  routers:
    billing:
      rule: "PathPrefix(`/billing/`)"
      service: billing
  services:
    billing:
      loadBalancer:
        servers:
          - url: "${BILLING_URL}"
```

## Utilisation

### Démarrage des services

```bash
# Démarrer tous les services
docker compose up -d
```

### Régénération de la configuration

Après avoir modifié les variables d'environnement ou le template :

#### Méthode 1 : Script automatique (recommandé)

```bash
# Régénérer et redémarrer automatiquement
./update-config.sh
```

#### Méthode 2 : Commandes manuelles

```bash
# Régénérer la configuration seulement
docker compose run --rm config-generator
```

> **ℹ️ Rechargement automatique**  
> Traefik recharge automatiquement sa configuration dès que le fichier `traefik.yml` est modifié.  
> **Aucun redémarrage de service n'est nécessaire** dans la plupart des cas.

### Vérification de la régénération

Après avoir exécuté `./update-config.sh`, vous devriez voir :

```bash
✅ Configuration Traefik générée dynamiquement
📁 Template: traefik.template.yml
📁 Output: traefik.yml
📋 Services configurés:
   /billing/ → https://api.zenyaa.com
   /iam/ → https://api.zenyaa.com
   /notification/ → https://api.zenyaa.com
   /ticket/ → https://api.zenyaa.com
```

## Accès aux services

Une fois démarré, Traefik expose les services sur :

- **Interface web Traefik** : http://localhost:5080
- **Proxy des services** : http://localhost:6080
  - `/billing/` → vers `BILLING_URL`
  - `/iam/` → vers `IAM_URL`  
  - `/notification/` → vers `NOTIFICATION_URL`
  - `/ticket/` → vers `TICKET_URL`

## Scripts disponibles

### `./update-config.sh`

Script principal pour régénérer la configuration Traefik :

- Exécute le générateur de configuration
- Redémarre automatiquement Traefik si nécessaire
- Compatible Linux, macOS et Windows (Git Bash/WSL)

### `./setup-hosts.sh`

Script pour configurer les entrées hosts locales (si nécessaire).

## Développement

### Modification du template

1. Éditez `config/traefik.template.yml`
2. Lancez `./update-config.sh` pour régénérer
3. La nouvelle configuration est automatiquement appliquée

### Ajout de nouvelles variables

1. Ajoutez la variable dans `.env` ou `.env.local`
2. Utilisez la variable dans `traefik.template.yml` avec la syntaxe `${VARIABLE_NAME}`
3. Régénérez avec `./update-config.sh`

### Debug

```bash
# Voir les logs du générateur de config
docker compose logs config-generator

# Voir les logs de Traefik
docker compose logs traefik

# Vérifier la configuration générée
cat config/traefik.yml
```

## Compatibilité

- **Linux** : Fonctionne nativement
- **macOS** : Fonctionne nativement  
- **Windows** : Nécessite Git Bash ou WSL

## Troubleshooting

### Erreur "service exited with code 0"

C'est normal ! Le service `config-generator` s'arrête après avoir généré la configuration.

### Traefik ne prend pas en compte les changements

**Solution 1** : Vérifiez les sorties du générateur de configuration :

```bash
docker compose logs config-generator
```

Si vous voyez la confirmation de génération mais Traefik ne réagit pas, essayez :

**Solution 2** : Redémarrez Traefik manuellement :

```bash
docker compose restart traefik
```

### Variables d'environnement non reconnues

Vérifiez que :

1. Les variables sont dans `.env` ou `.env.local`
2. La syntaxe dans le template est `${VARIABLE_NAME}`
3. Vous avez régénéré la configuration avec `./update-config.sh`

### Configuration non appliquée

Si malgré la régénération réussie, les changements ne sont pas pris en compte :

1. Vérifiez le contenu généré :
   ```bash
   cat config/traefik.yml
   ```

2. Redémarrez complètement les services :
   ```bash
   docker compose down
   docker compose up -d
   ```
