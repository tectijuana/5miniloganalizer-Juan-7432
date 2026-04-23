<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/a44bb0d7-30f9-4fff-95bf-f08277476255" />

# Practica 4.2 Mini Cloud Log Analyzer (Bash + ARM64 + GNU Make)

## Datos 

- Nombre: Juan David Fernández Hernández 
- Fecha: 22/04/2026
- Materia: Lenguajes de interfaz
- Docente: Rene Solis Reyes

---

# Introducción

Los sistemas modernos de cómputo en la nube generan continuamente registros (*logs*) que permiten monitorear el estado de servicios, detectar fallas y activar alertas ante eventos críticos.

En esta práctica se desarrollará un módulo simplificado de análisis de logs, implementado en **ARM64 Assembly**, inspirado en tareas reales de monitoreo utilizadas en sistemas cloud, observabilidad y administración de infraestructura.

El programa procesará códigos de estado HTTP suministrados mediante entrada estándar (stdin):

```bash id="y1gcmc"
cat logs.txt | ./analyzer
```

---

# Objetivo general

Diseñar e implementar, en lenguaje ensamblador ARM64, una solución para procesar registros de eventos y detectar condiciones definidas según la variante asignada.

---
# Objetivos específicos

## Aplicar:

* programación en ARM64 bajo Linux
* manejo de registros
* direccionamiento y acceso a memoria
* instrucciones de comparación
* estructuras iterativas en ensamblador
* saltos condicionales
* uso de syscalls Linux
* compilación con GNU Make
* control de versiones con GitHub Classroom

Estos temas se alinean con contenidos clásicos de flujo de control, herramientas GNU, manejo de datos y convenciones de programación en ensamblador.   

---
# Estructura del repositorio

```text
cloud-log-analyzer/
├── README.md
├── Makefile
├── run.sh
├── src/
│   └── analyzer.s
├── data/
│   ├── logs_A.txt
│   ├── logs_B.txt
│   ├── logs_C.txt
│   ├── logs_D.txt
│   └── logs_E.txt
├── tests/
│   ├── test.sh
│   └── expected_outputs.txt
└── instructor/
    └── VARIANTES.md
```

---

# Requisitos técnicos

- Sistema objetivo: **AWS Ubuntu 24 ARM64**.
- Arquitectura: **AArch64 Linux**.
- Ensamblador: **GNU assembler** (o equivalente compatible para construir en entorno alterno).
- Restricciones:
  - Sin libc.
  - Sin lenguaje C.
  - Solo syscalls Linux + Bash + Make.

---

# Flujo sugerido en GitHub Classroom

1. El docente crea la actividad en GitHub Classroom.
2. Cada estudiante acepta su repositorio individual.
3. Clona su repositorio en instancia AWS ARM64.
4. Implementa su variante en `src/analyzer.s`.
5. Ejecuta:
   - `make`
   - `make run`
   - `make test`
6. Hace commit/push y entrega el enlace del repositorio.

---

# Instrucciones de uso en AWS Ubuntu 24 ARM64

### 1 Compilar

```bash
make
```

### 2 Ejecutar ejemplo base

```bash
make run
```

### 3 Ejecutar pruebas

```bash
make test
```

### 4 Limpiar artefactos

```bash
make clean
```
---

## Variantes Asignada


- **B**: encontrar código más frecuente.

---

## Evidencia en Asciinema 🎥

- Link: https://asciinema.org/a/9SqfpVBnO9n04Om8 


## Conclusión 

En esta práctica se desarrolló un analizador de logs en lenguaje ensamblador ARM64, capaz de procesar códigos HTTP desde la entrada estándar y determinar el código más frecuente. A través de este ejercicio se reforzaron conceptos fundamentales como el manejo de registros, control de flujo, acceso a memoria y uso de llamadas al sistema en Linux.

Además, se comprendió la importancia de diseñar estructuras eficientes a bajo nivel, como el uso de arreglos para el conteo de frecuencias, lo cual simula escenarios reales en sistemas de monitoreo en la nube. Esta práctica permitió apreciar cómo tareas comunes en lenguajes de alto nivel requieren un manejo más detallado y preciso en ensamblador, fortaleciendo la comprensión del funcionamiento interno de los sistemas.

---





