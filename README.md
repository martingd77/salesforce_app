# Customer Sentiment & Notification Hub

## 🔹 Resumen
Este proyecto demuestra un flujo completo de automatización en Salesforce que:

1. Detecta cambios en el mensaje del cliente (`Latest_Client_Message__c`) en un **Case**.
2. Analiza el sentimiento del mensaje mediante un **Apex callout a API externa** (mock para demo).
3. Registra el sentimiento (Positive / Neutral / Negative) y su score en el Case.
4. Si el sentimiento es negativo:
   - Crea automáticamente una **Task/Activity** relacionada al Case.
   - Actualiza campos del Case según reglas de negocio.
   - Envía notificaciones por correo.
   - Registra logs internos mediante `LogService`.

---

## 🔹 Tecnologías y conceptos usados
- **Apex Triggers**:
  - `CaseTrigger` → Detecta cambios en `Latest_Client_Message__c`
  - `CaseTriggerHandler.cls` → Lógica de negocio y detección de cambios
- **Apex Queueable Jobs**:
  - `SentimentJob.cls` → Ejecuta callouts de forma asíncrona (permite callouts fuera del contexto del trigger)
- **Apex Services**:
  - `SentimentService.cls` → Lógica de API callout
  - `CaseSentimentDomain.cls` → Lógica de negocio y bulkification (método invocable disponible para Flow si se requiere)
  - `LogService.cls` → Registro de logs internos
- **DTOs** para request/response de API
- **Test classes** >90% coverage
- **Best practices**:
  - Separación de capas (Handler → Job → Service)
  - Bulkification
  - Procesamiento asíncrono con Queueable para callouts
  - Mock para HTTP Callouts
- **Metadatos**:
  - Campos custom en Case (`Latest_Client_Message__c`, `Sentiment__c`, `Sentiment_Score__c`)

---

## 🔹 Instalación / Despliegue
1. Clonar este repositorio.
2. Desplegar con **Salesforce CLI** (`sfdx force:source:deploy -p force-app`) en tu Org de sandbox o dev.
3. Configurar **Named Credential** (`SentimentAPI`) / Remote Site para la API de Sentiment (puede ser mock).
4. El trigger se activa automáticamente al desplegar el código.

---

## 🔹 Uso
1. Crear o actualizar un **Case** con un mensaje de cliente en `Latest_Client_Message__c`.
2. El **Trigger** se dispara automáticamente:
   - Detecta el cambio en `Latest_Client_Message__c`.
   - Encola un `SentimentJob` (Queueable) para procesar el callout de forma asíncrona.
   - El job ejecuta el callout a la API de sentimiento.
   - Actualiza los campos `Sentiment__c` y `Sentiment_Score__c` en el Case.
3. Verificar resultados en:
   - Campos Case: `Sentiment__c`, `Sentiment_Score__c`
   - Logs en objeto `Log__c` (si está configurado)
   - Debug logs para ver el procesamiento asíncrono

---

## 🔹 Diagrama de Arquitectura

**Flujo:**
```
Case Update (Latest_Client_Message__c cambia)
    ↓
CaseTrigger (after update)
    ↓
CaseTriggerHandler.run()
    ↓
Detecta cambios → Filtra Cases a procesar
    ↓
System.enqueueJob(new SentimentJob(cases))
    ↓
SentimentJob.execute() [Queueable - permite callouts]
    ↓
Para cada Case:
    SentimentService.callAPI(text)
    ↓
Actualiza Case: Sentiment__c, Sentiment_Score__c
```


## 🔹 Testing
- Todos los servicios tienen **Test Classes**:
  - `SentimentServiceTest`
  - `CaseSentimentDomainTest`
  - `CaseTriggerHandlerTest` (si existe)
  - `LogServiceTest`
- **Callouts** mockeados con `HttpCalloutMock`.
- Cobertura >90%.
- Para ejecutar tests: `sfdx force:apex:test:run --resultformat human`

---

## 🔹 Próximos pasos / mejoras
- Integrar con **LWC** para mostrar sentimiento en tiempo real.
- Conectar con **Agent-Force / AI Salesforce**.
- Automatización de emails avanzados según score de sentimiento.