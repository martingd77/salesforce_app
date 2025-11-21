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
- **Salesforce Flow**:
  - Record-Triggered Flow (cuando cambia `Latest_Client_Message__c`)
  - Subflows para casos negativos
- **Apex**:
  - `SentimentService.cls` → Lógica de API callout
  - `CaseSentimentDomain.cls` → Lógica de negocio y bulkification
  - `ActivityCreator.cls` → Creación de Task/Activity desde Flow
  - `LogService.cls` → Registro de logs internos
- **DTOs** para request/response de API
- **Test classes** >90% coverage
- **Best practices**:
  - Separación de capas
  - Bulkification
  - Invocable Methods para Flow
  - Mock para HTTP Callouts
- **Metadatos**:
  - Campos custom en Case (`Latest_Client_Message__c`, `Sentiment__c`, `Sentiment_Score__c`)

---

## 🔹 Instalación / Despliegue
1. Clonar este repositorio.
2. Desplegar con **Salesforce CLI** (`sfdx force:source:deploy -p force-app`) en tu Org de sandbox o dev.
3. Configurar **Named Credential** / Remote Site para la API de Sentiment (puede ser mock).
4. Activar Flows:
   - `Record_Triggered_Flow_Case_Sentiment`
   - `Subflow_Negative_Case_Management`

---

## 🔹 Uso
1. Crear o actualizar un **Case** con un mensaje de cliente en `Latest_Client_Message__c`.
2. Flow se dispara automáticamente:
   - Analiza el sentimiento.
   - Actualiza campos en Case.
   - Crea Task si es negativo.
   - Envía correo y registra log.
3. Verificar resultados en:
   - Related List: Tasks/Activities
   - Campos Case: `Sentiment__c`, `Sentiment_Score__c`
   - Logs en objeto `Log__c`

---

## 🔹 Diagrama de Arquitectura
<!-- TO DO -->

**Flujo:**


## 🔹 Testing
- Todos los servicios tienen **Test Classes**:
  - `SentimentServiceTest`
  - `CaseSentimentDomainTest`
  - `LogServiceTest`
- **Callouts** mockeados con `HttpCalloutMock`.
- Cobertura >90%.
- Para ejecutar tests: `sfdx force:apex:test:run --resultformat human`

---

## 🔹 Próximos pasos / mejoras
- Integrar con **LWC** para mostrar sentimiento en tiempo real.
- Conectar con **Agent-Force / AI Salesforce**.
- Automatización de emails avanzados según score de sentimiento.