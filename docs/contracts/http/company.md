# HTTP Sellevate.Company

| Метод | Маршрут | Доступ и политики |
| --- | --- | --- |
| GET | `/companies` | JWT, Контекст организации |
| POST | `/companies` | JWT, Контекст организации |
| DELETE | `/companies/{companyId}` | JWT, Контекст организации |
| GET | `/companies/{companyId}` | JWT, Контекст организации |
| PUT | `/companies/{companyId}` | JWT, Контекст организации |
| GET | `/companies/{companyId}/briefing` | JWT, Контекст организации |
| POST | `/companies/{companyId}/briefing` | JWT, Контекст организации |
| GET | `/companies/{companyId}/contacts` | JWT, Контекст организации |
| POST | `/companies/{companyId}/contacts` | JWT, Контекст организации |
| DELETE | `/companies/{companyId}/contacts/{contactId}` | JWT, Контекст организации |
| PUT | `/companies/{companyId}/contacts/{contactId}` | JWT, Контекст организации |
| PUT | `/companies/{companyId}/follow-up` | JWT, Контекст организации |
| GET | `/companies/{companyId}/logs` | JWT, Контекст организации |
| POST | `/companies/{companyId}/logs` | JWT, Контекст организации |
| POST | `/companies/{companyId}/logs/parse` | JWT, Контекст организации |
| DELETE | `/companies/{companyId}/logs/{logId}` | JWT, Контекст организации |
| PUT | `/companies/{companyId}/logs/{logId}` | JWT, Контекст организации |
| GET | `/companies/{companyId}/personas` | JWT, Контекст организации |
| POST | `/companies/{companyId}/personas` | JWT, Контекст организации |
| POST | `/companies/{companyId}/personas/generate` | JWT, Контекст организации |
| DELETE | `/companies/{companyId}/personas/{personaId}` | JWT, Контекст организации |
| GET | `/companies/{companyId}/practice-calls` | JWT, Контекст организации |
| POST | `/companies/{companyId}/practice-calls` | JWT, Контекст организации |
| GET | `/companies/{companyId}/readiness` | JWT, Контекст организации |
| GET | `/companies/{companyId}/recent-goals` | JWT, Контекст организации |
| PUT | `/companies/{companyId}/status` | JWT, Контекст организации |
