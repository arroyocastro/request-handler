#!/bin/bash

set -e  # Detener el script si hay un error
set -x  # Mostrar los comandos ejecutados

# Limpiar y compilar el proyecto
mvn clean package

# Construir la imagen Docker
docker build -t request-handler .

# Guardar la imagen en un archivo
docker save request-handler > request-handler.tar

# Importar la imagen en MicroK8s
microk8s ctr image import request-handler.tar

# Eliminar el despliegue anterior si existe
microk8s kubectl delete -f request-handler-kubernetes.yaml || true

# Aplicar el nuevo despliegue
microk8s kubectl apply -f request-handler-kubernetes.yaml