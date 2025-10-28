# Cloudflare Tunnels - Guide Complet

## Configuration : UN SEUL TUNNEL pour MULTIPLE SERVICES

Guide simplifié pour exposer plusieurs services locaux via un seul tunnel Cloudflare.

---

## 📋 Votre configuration

```
Port local  →  Domaine                           (tous via UN seul tunnel)
──────────────────────────────────────────────────────────────────────
3000        →  ${NAMESPACE}-3000.innov-ds.com
8081        →  ${NAMESPACE}-8081.innov-ds.com
6080        →  ${NAMESPACE}-6080.innov-ds.com
```

**Exemple :** avec `NAMESPACE=test` → `test-3000.innov-ds.com`

**Un tunnel = plusieurs domaines** ✅

---

## 🚀 Démarrage rapide (5 min)

### Étape 1 : Installer cloudflared

**macOS :**
```bash
brew install cloudflared
```

**Linux (Debian/Ubuntu) :**
```bash
sudo apt-get update && sudo apt-get install cloudflared
```

**Windows :**
Télécharger depuis : https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/

### Étape 2 : S'authentifier

```bash
cloudflared tunnel login
```

Vous serez redirigé vers Cloudflare. Acceptez et un fichier de credentials est créé :
```
~/.cloudflared/[LONG_ID].json
```

### Étape 3 : Créer le tunnel (UNE SEULE FOIS)

```bash
NAMESPACE=test # remplacez par votre trigramme
cloudflared tunnel create ${NAMESPACE}-tunnel
```

Résultat :
```
Tunnel credentials have been saved to:
~/.cloudflared/[TUNNEL_ID].json

Tunnel '${NAMESPACE}-tunnel' created with ID: [id]
```

### Étape 4 : Configurer les routes DNS

```bash
NAMESPACE=test # remplacez par votre trigramme
cloudflared tunnel route dns ${NAMESPACE}-tunnel ${NAMESPACE}-3000.innov-ds.com
cloudflared tunnel route dns ${NAMESPACE}-tunnel ${NAMESPACE}-8081.innov-ds.com
cloudflared tunnel route dns ${NAMESPACE}-tunnel ${NAMESPACE}-6080.innov-ds.com
```

### Étape 5 : Créer le fichier de configuration

Créez `~/.cloudflared/config.yml` :

```yaml
# Nom du tunnel
tunnel: ${NAMESPACE}-tunnel
# Fichier de credentials d'authentification
# Créé automatiquement lors de 'cloudflared tunnel login'
credentials-file: ${HOME}/.cloudflared/${TUNNEL_ID}.json

ingress:
  - hostname: ${NAMESPACE}-3000.innov-ds.com
    service: http://localhost:3000
  
  - hostname: ${NAMESPACE}-8081.innov-ds.com
    service: http://localhost:8081
  
  - hostname: ${NAMESPACE}-6080.innov-ds.com
    service: http://localhost:6080
  
  # Route par défaut pour les autres domaines
  - service: http_status:404
```

**Important :** Remplacez `[TUNNEL_ID]` par votre ID réel et `${NAMESPACE}` par votre trigramme (ex: `test`).

### Étape 6 : Lancer le tunnel

```bash
cloudflared tunnel run --config ~/.cloudflared/config.yml
```

Résultat attendu :
```
2025-10-28T10:15:30Z INF Starting tunnel connector from UNIX socket tunnel.sock
2025-10-28T10:15:32Z INF Connected to fra (DFW)
2025-10-28T10:15:32Z INF Tunnel running
```

### Étape 7 : Tester l'accès

Dans un autre terminal :

```bash
NAMESPACE=test # remplacez par votre trigramme
curl https://${NAMESPACE}-3000.innov-ds.com
curl https://${NAMESPACE}-8081.innov-ds.com
curl https://${NAMESPACE}-6080.innov-ds.com
```

**C'est tout ! Votre tunnel est actif.** ✅

---

## 📝 Configuration détaillée


### Trouver votre TUNNEL_ID

```bash
# Voir l'ID du tunnel
cloudflared tunnel list

# Afficher le chemin exact du fichier credentials
ls ~/.cloudflared/*.json
```

**Exemple :**
```
Tunnel ID: 1a2b3c4d-5e6f-7g8h-9i0j-1k2l3m4n5o6p
Credentials file: ~/.cloudflared/6dfxxxd220ec.json
```

---

## 🏃 Utilisation quotidienne

### Démarrer le tunnel

```bash
# Démarrer en foreground (pour tester)
cloudflared tunnel run --config ~/.cloudflared/config.yml

# Démarrer en background
nohup cloudflared tunnel run --config ~/.cloudflared/config.yml > /tmp/tunnel.log 2>&1 &

# Ou avec screen/tmux
screen -S tunnel cloudflared tunnel run --config ~/.cloudflared/config.yml
```

### Vérifier l'état

```bash
NAMESPACE=test # remplacez par votre trigramme
# Lister les tunnels créés
cloudflared tunnel list

# Voir les infos du tunnel
cloudflared tunnel info ${NAMESPACE}-tunnel

# Voir les logs en temps réel
cloudflared tunnel logs ${NAMESPACE}-tunnel

# Voir les connexions actives
ps aux | grep cloudflared
```

### Arrêter le tunnel

```bash
# Si en foreground : Ctrl+C

# Si en background
pkill -f "cloudflared tunnel run"
```
