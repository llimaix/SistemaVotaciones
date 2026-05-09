# Sistema de Votaciones 
 
## Objetivo del proyecto 
Desarrollar la propuesta y una implementación básica de un Sistema de Votaciones, aplicando conceptos de planificación, metodologías ágiles (Scrum), análisis mediante historias de usuario, diseño del sistema, control de versiones y despliegue. 

- Descripción del problema: 
Actualmente, los procesos de votación se realizan de forma manual, lo cual genera problemas como: 
• Errores en conteo de votos  
• Retrasos en la consolidación de resultados  
• Falta de control en mesas electorales  
• Dificultad para auditar resultados  

- Se requiere diseñar e implementar un sistema que permita gestionar el proceso de votación de manera ordenada, rápida y confiable. 
 
## El sistema debe incluir al menos: 
• Login  
• Crear usuarios  
• Crear votaciones  
• Crear mesas  
• Registrar resultados  
• Consultar resultados 

### Diseño del sistema 
## Debe incluir: 
• Diseño de módulos  
• Modelo de base de datos  
• Prototipos de interfaz 
 
 
### Desarrollo 
## Implementación mínima funcional de: 
• Login  
• CRUD de usuarios  
• Gestión de votaciones  
• Gestión de mesas  
• Registro de resultados 

# Arquitectura
Voy quiero hacer una SPA con Angular en su ultima versión y Java 21. Todo montado sobre AWS. 
Con terraform se requiere levantar los recursos iniciales para al almacenamiento de los estados de terraform con un pipeline robusto capaz de accionarse una vez con escenarios de fallo controlados sin dejar recursos huerfanos o errores en el despliegue.
La infra de terraform debeá ser un bucket de multimedia, uno de serverless y uno para el SPA, un Cloudfront y un modulo de secret manager. 

El api gateway y las lambdas se deben desplegar con Serverless Framework en estructura ordenedad, como por ejemplo una carpeta para cada función, con separación de logica de codigo e integración con infra estructura. Todas las variables del sistema deberán de estar almacenados en secret manager para proteger datos sensibles. 

La base de datos esta en un servidor independiente. 

Todo debe ser deplegado por CI/CD, en Azure DevOps es mas seguro usar service connection así que nos iremos por eso para los pipelines. 