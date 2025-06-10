#!/bin/sh
echo "Esperando que el Docker daemon esté disponible en tcp://localhost:2375..."
while ! docker info >/dev/null 2>&1; do
  sleep 1
done
echo "Docker está listo 🎉"
