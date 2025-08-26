#!/usr/bin/env python3
"""
Générateur de configuration Traefik DYNAMIQUE
Lit le template traefik.yml.template et génère traefik.yml
Extrait automatiquement les variables ${VAR_NAME} du template
"""

import os
import re
from pathlib import Path

def extract_template_variables(template_content):
    """Extrait les variables ${VAR_NAME} du template"""
    pattern = r'\$\{\s*([A-Z_]+)\s*\}'
    variables = re.findall(pattern, template_content)
    return sorted(set(variables))

def generate_config():
    """Génère traefik.yml depuis le template et les variables d'environnement"""
    
    template_file = Path("traefik.template.yml")
    output_file = Path("traefik.yml")
    
    if not template_file.exists():
        print(f"❌ Template {template_file} introuvable")
        exit(1)
    
    # Lire le template
    template_content = template_file.read_text()
    
    # Extraire les variables du template
    variables = extract_template_variables(template_content)

    default_url = os.getenv("DEFAULT_URL", "NOT_SET")

    # Remplacer les variables
    config_content = template_content
    services_found = []
    
    for var in variables:
        value = os.getenv(var, default_url)
        if value:
            # Remplacer ${VAR_NAME} (avec ou sans espaces)
            pattern = r'\$\{\s*' + re.escape(var) + r'\s*\}'
            config_content = re.sub(pattern, value, config_content)
            
            # Déduire le nom du service
            service_name = var.replace('_URL', '').lower()
            services_found.append(f"/{service_name}/ → {value}")
        else:
            print(f"⚠️  Variable {var} non définie")
    
    # Écrire la configuration finale
    output_file.write_text(config_content)
    
    print(f"\n✅ Configuration Traefik générée dynamiquement")
    print(f"📁 Template: {template_file}")
    print(f"📁 Output: {output_file}")
    print(f"📋 Services configurés:")
    for service in services_found:
        print(f"   {service}")
    
    return True

if __name__ == "__main__":
    generate_config()
