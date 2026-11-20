# CityWeather

Desarrollo una app llamada CityWeather en mi tiempo libre los fines de semana, es una app en SwiftUI para visualizar el tiempo, la utilizo como proyecto “semilla” para tener una base arquitectónica reutilizable en otros proyectos que se necesita crear aplicaciones nuevas. Incluye separación de capas, patrones de diseño, persistencia, consumo de servicios…

La aplicacion tiene 2 pantallas:
  - CitySelection: Selecciona la localidad que deseas saber el tiempo desde el buscador o desde tu ubicación
  - Dashboard: Muestra la información meteorológica de la ciudad seleccionada del día actual y previsión de 5 días

La ciudad seleccionada se guarda para que, en los siguientes arranques, la aplicación acceda directamente al Dashboard.
Para volver a seleccionar otra ciudad, basta con pulsar el icono del engranaje situado en el Dashboard arriba la derecha, que permite regresar a CitySelection.

La aplicación admite español e inglés, adaptándose al idioma configurado en iOS. También respeta automáticamente la apariencia del dispositivo (modo claro u oscuro).


---
## 1. API pública elegida

La app usa dos APIs públicas:

| Uso | API | Endpoint | Dónde se define |
|---|---|---|---|
| Búsqueda de ciudades (pantalla CitySelection) | **Open-Meteo Geocoding**  | `GET https://geocoding-api.open-meteo.com/v1/search?name=…&count=5&language=…` | CityWeather/Network/GeoCodingServices/GeoCodingServicesEndPoints |
| Tiempo actual y previsión (Dashboard) | **OpenWeatherMap** | `GET /data/2.5/weather` y `GET /data/2.5/forecast` | CityWeather/Network/MapServices/MapServicesEndpoints.swift |

Los parámetros de la búsqueda se montan en `CityWeather/Network/GeoCodingServices/GeoCodingRouter.swift` (`queryItems()`, en la parte con `case .getDataSearch(let name)`). Los de OpenWeatherMap, en `CityWeather/Network/MapServices/MapServicesRouter.swif`.

Para la api que utiliza en la pantalla de Búsqueda puedes ver la documentación desde aquí
https://github.com/open-meteo/open-meteo

Para la api OpenWeather que se utiliza en el Dashboard puedes ver la documentación aquí 
https://openweathermap.org/api/current?collection=current_forecast 
https://openweathermap.org/api/forecast5?collection=current_forecast

---
## 2. Cómo ejecutar la app

Requisitos: Xcode 27 y un simulador o dispositivo con iOS 18 o superior.

1. Clona el repositorio y abre `CityWeather.xcodeproj`.
2. Selecciona el esquema **CityWeather** y un dispositivo.
3. Pulsa **⌘R** para ejecutar.

Ejecutar los tests: **⌘U** con el mismo esquema 

**Primer arranque:** si no hay ciudad guardada, la app abre directamente la búsqueda. Si ya hay una ciudad guardada, salta al Dashboard de esa ciudad. 

La ciudad seleccionada se guarda en datos persistentes para que, en los siguientes arranques, la aplicación acceda directamente al Dashboard.
Para volver a seleccionar otra ciudad, basta con pulsar el icono del engranaje situado en el Dashboard arriba la derecha, que permite regresar a CitySelection.

--
## 3. Requisitos funcionales

### 3.1 Pantalla de búsqueda

- La app utiliza una pantalla llamada CitySelection en el que utiliza un buscador que va mostrando los resultados según escribe el usuario
- El usuario podrá pulsar en el botón de Usar ubicación actual y mostrará el resultado en la lista.

### 3.2 Cancelación de búsquedas anteriores
Si el usuario escribe otra búsqueda antes de que termine la anterior, la petición en curso se cancela y no se muestran resultados antiguos.

Implementación en `CityWeather/Presentation/Representation/ViewModels/CitySelection/CitySelectionViewModel.swift`:

| Paso | Línea | Qué hace |
|---|---|---|
| Cancelar la búsqueda anterior | `:95` | `searchTask?.cancel()` cada vez que cambia el texto |
| Guardar la búsqueda nueva | `:103` | `searchTask = Task { … }`, la tarea que se puede cancelar |
| Debounce de 100 ms | `:104` | `try? await Task.sleep(for: searchDebounce)`: si llega otra tecla antes, el `sleep` termina al cancelarse la tarea |
| No lanzar la petición si ya se canceló | `:105` | `guard !Task.isCancelled else { return }`: una búsqueda superada nunca llega a la red |
| Descartar la respuesta si llegó tarde | `:114` | `… as? GeoCodingSearchWrapper, !Task.isCancelled`: aunque la red ignorara la cancelación, el resultado obsoleto no se pinta |
| Cancelación no es un error | `:118` y `:124-126` | `isCancellation` reconoce `CancellationError` y `URLError(.cancelled)`; en ese caso no se vacía la lista ni se registra un error |

El debounce de 100 ms viene de `CityWeather/Resources/Constants.swift:29` y se inyecta en el ViewModel en `CitySelectionViewModel.swift

Un texto vacío cancela la búsqueda en curso y vacía la lista: `CitySelectionViewModel.swift:94-101`.

### 3.3 Pantalla de detalle
- Al tocar una fila, `CitySelectionView.swift:52-53` llama a `viewModel.didTapContinue(city:)`, que guarda la ciudad y activa la navegación (`CitySelectionViewModel.swift:172`).
- La navegación está en `CitySelectionView.swift:63` (`navigationDestination`) y crea el Dashboard con `CitySelectionConnector.swift:20` (`navigateToDashboard`).
- El Dashboard es `CityWeather/Presentation/Platform/Scenes/Dashboard/View/DashboardView.swift:10` y muestra estos campos:
  - **temperatura, descripción y mínima/máxima**: `TemperatureView` en la línea 70 (`:75`, `:79` y `:83`);
  - **previsión por horas** (5 franjas): `TimeHoursView` en la línea 91, usada en la 36;
  - **previsión de 5 días**: `DayForecast` en la línea 124, usada en la 37.
- Los datos los carga `DashboardViewModel.swift:36` (`loadWeather`), con los casos de uso de tiempo y previsión.

---

## 4. Requisitos técnicos

### 4.1 Arquitectura
El proyecto se organiza en diferentes capas, dentro de `CityWeather/`:

| Capa | Carpetas | Responsabilidad |
|---|---|---|
| **Data** | `Data/` y `Network/` | Habla con la red (`URLSession`), decodifica el JSON, implementa los repositorios y gestiona la caché y el almacenamiento local. |
| **Domain** | `Domain/` | Casos de uso (`AsyncUseCase`) y contratos de repositorio (`ModelProtocol`). No depende de SwiftUI ni de la red. |
| **Presentation** | `Presentation/Representation/` y `Presentation/Platform/` | ViewModels, factorías de casos de uso, vistas SwiftUI, conectores de navegación y componentes. |

**Regla de dependencias:** `Presentation → Domain ← Data`. El ViewModel solo conoce casos de uso; el caso de uso solo conoce el protocolo del repositorio; el repositorio de Data implementa ese protocolo.

Ejemplo de la cadena para la búsqueda:

| Pieza | Archivo y línea |
|---|---|
| ViewModel que crea el caso de uso | `Presentation/Representation/ViewModels/CitySelection/CitySelectionViewModel.swift:110` (`fetchCitySuggestions`) |
| Caso de uso | `Domain/UseCase/GeoCodingServices/GetDataSearchGeoUseCase.swift:10` (clase), `:22` (`execute`) |
| Contrato de repositorio en Domain | `Domain/ModelProtocol/GeoCodingServicesModelProtocol.swift:14-15` |
| Repositorio que implementa el contrato | `Data/Repositories/GeoCodingServicesRepository.swift:10` |
| Factoría que monta la cadena | `Presentation/Representation/GeoCodingServiceUseCaseFactory.swift:10` y `:36` |

**Por qué `Presentation/` tiene dos carpetas:** `Representation/` contiene la lógica de presentación (ViewModels y factorías), que se testea con tests unitarios normales; `Platform/` contiene lo dependiente de SwiftUI (vistas, conectores, componentes y `App`). Ambas forman la capa Presentation.

**Protocolos del ViewModel:** `CitySelectionViewModel.swift:11` (`Output`) y `:20` (`Input`) están marcados con `@MainActor`. Así todo el estado publicado para la UI se modifica en el hilo principal.


### 4.2 UI en SwiftUI
Todas las pantallas están en SwiftUI: `CityWeatherApp.swift:11` (`App`, con `NavigationStack`), `CitySelectionView` y `DashboardView`. 

### 4.3 Concurrencia y asincronía
- Toda la lógica de búsqueda es `async/await`: `GetDataSearchUseCase.execute` (`GetDataSearchGeoUseCase.swift:22`), el repositorio (`GeoCodingServicesRepository.swift:20`) y el cliente de red (`NetworkDispatcher.swift:21`, `func call`).
- La cancelación usa `Task` y `Task.isCancelled` ,además aborta la petición HTTP cuando su tarea se cancela.
- La caché es un **`actor`** (`GeoCodingSearchCache.swift`), así que el diccionario interno solo lo toca una tarea a la vez.
- Los protocolos del ViewModel son `@MainActor` 

### 4.4 Caché por búsqueda con caducidad
Se ha implementado el requisito por query, caducidad de 5 minutos, devolver el cacheado sin red si es válido y renovarlo si caduca. 

| Pieza | Archivo y línea | Qué hace |
|---|---|---|
| Tiempo de vida: **5 minutos** | `CityWeather/Resources/Constants.swift:30` | `cacheTimeToLive = 300` 300 segundos (5 minutos) |
| Almacén | `CityWeather/Data/Cache/GeoCodingSearchCache.swift:10-18` | `actor`, diccionario de entradas con fecha de guardado |
| Clave normalizada | `GeoCodingSearchCache.swift:45-47` | Quita espacios y pasa a minúsculas: `"Madrid"`, `" madrid "` comparten entrada |
| Lectura | `GeoCodingSearchCache.swift:28-31` | Elimina las caducadas (`removeExpiredEntries`, línea 37) y devuelve la válida |
| Regla de caducidad | `GeoCodingSearchCache.swift:41-43` | Válida si `now − storedAt < timeToLive` |
| Escritura | `GeoCodingSearchCache.swift:33-35` | Guarda el resultado con la hora actual |
| Uso desde el repositorio | `CityWeather/Data/Repositories/GeoCodingServicesRepository.swift:20-27` | 1) si hay caché válida, la devuelve (línea 21-22); 2) si no, llama a la red (línea 24); 3) guarda el resultado (línea 25) |
| Errores no se guardan | `GeoCodingServicesRepository.swift:24-25` | si la línea 24 lanza un error, la 25 no se ejecuta |
| Reloj inyectable | `GeoCodingSearchCache.swift:18` y `:22` | `now` se pasa al crear la caché, así los tests controlan el tiempo sin esperas |

¿Por qué la caché está en el repositorio y no en el ViewModel, en el caso de uso (usecase) o en el APIClient?  El repositorio es quien coordina las fuentes de datos (red y memoria). Domain no sabe que la caché existe y Presentation tampoco. La caché es un detalle de Data.


### 4.5 Tests
El target `CityWeatherTests` tiene 113 tests. Se agrupan por capa, igual que el código

---
---
## 
