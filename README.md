# CityWeather

Desarrollo una app llamada CityWeather en mi tiempo libre los fines de semana. El proyecto está diseñado con especial atención a la arquitectura y la calidad del código, aplicando patrones de diseño y buenas prácticas de desarrollo iOS para conseguir una estructura escalable y mantenible.

La aplicación tiene 2 pantallas:
  - CitySelection: Selecciona la localidad que deseas saber el tiempo desde el buscador o desde tu ubicación
  - Dashboard: Muestra la información meteorológica de la ciudad seleccionada del día actual y previsión de 5 días

La ciudad seleccionada se guarda para que, en los siguientes arranques, la aplicación acceda directamente al Dashboard.
Para volver a seleccionar otra ciudad, basta con pulsar el icono del engranaje situado en el Dashboard arriba a la derecha, que permite regresar a CitySelection.

La aplicación admite español e inglés, adaptándose al idioma configurado en iOS. También respeta automáticamente la apariencia del dispositivo (modo claro u oscuro).


<img width="1206" height="2622" alt="City_clearmode" src="https://github.com/user-attachments/assets/538664b2-bc3e-4bbb-952f-d6540c8d1a54" />
<img width="1206" height="2622" alt="Dashboard_clearmode" src="https://github.com/user-attachments/assets/7cb90f71-eb23-4502-8fbd-79d16931dfd2" />
</br>
<img width="1206" height="2622" alt="City_darkmode" src="https://github.com/user-attachments/assets/9486b6f9-194f-4ebd-b798-037f5207f2ea" />
<img width="1206" height="2622" alt="Dashboard_darkmode" src="https://github.com/user-attachments/assets/616efe83-51aa-44ad-814f-12b9f2f7487b" />


---
## 1. API pública elegida

La app usa dos APIs públicas:

| Uso | API | Endpoint | Dónde se define |
|---|---|---|---|
| Búsqueda de ciudades (pantalla CitySelection) | **Open-Meteo Geocoding**  | `GET https://geocoding-api.open-meteo.com/v1/search?name=…&count=5&language=…` | CityWeather/Network/GeoCodingServices/GeoCodingServicesEndPoints.swift |
| Tiempo actual y previsión (Dashboard) | **OpenWeatherMap** | `GET /data/2.5/weather` y `GET /data/2.5/forecast` | CityWeather/Network/MapServices/MapServicesEndpoints.swift |

Los parámetros de la búsqueda (Open-Meteo) se montan en `CityWeather/Network/GeoCodingServices/GeoCodingRouter.swift` (`queryItems()`, en la parte con `case .getDataSearch(let name)`). 
Los de OpenWeatherMap, en `CityWeather/Network/MapServices/MapServicesRouter.swift`.

Para la API que se utiliza en la pantalla de Búsqueda (Open-Meteo) puedes ver la documentación desde aquí
https://open-meteo.com/en/docs/geocoding-api?language=es

Para la API OpenWeather que se utiliza en el Dashboard puedes ver la documentación aquí

https://openweathermap.org/api/current?collection=current_forecast

https://openweathermap.org/api/forecast5?collection=current_forecast

---
## 2. Cómo ejecutar la app

Requisitos: Xcode 27 y un simulador o dispositivo con iOS 18 o superior.

1. Clona el repositorio y abre `CityWeather.xcodeproj`. Por ejemplo abre Terminal, sitúate en el directorio donde quieras descargar el proyecto y ejecuta: git clone https://github.com/Juanmadlc/CityWeather.git
2. Selecciona el esquema **CityWeather** y un dispositivo.
3. Pulsa **⌘R** para ejecutar.

Ejecutar los tests: **⌘U** con el mismo esquema 

**Primer arranque:** si no hay ciudad guardada, la app abre directamente la búsqueda. Si ya hay una ciudad guardada, salta al Dashboard de esa ciudad. 

La ciudad seleccionada se guarda en datos persistentes para que, en los siguientes arranques, la aplicación acceda directamente al Dashboard.
Para volver a seleccionar otra ciudad, basta con pulsar el icono del engranaje situado en el Dashboard arriba a la derecha, que permite regresar a CitySelection.

Si se ejecuta con simulador recomiendo:
- Activar en el simulador la ubicación simulada. Pulsar en device y después en Location y elegir cualquier ciudad.
- Si queremos visualizar el teclado táctil en el simulador (en vez de escribir con el teclado del mac), pulsar en Device -> Keyboard -> Keyboard Capture (desactivar Simulate Hardware Keyboard)

<img width="1308" height="917" alt="simulador berlin" src="https://github.com/user-attachments/assets/c51f3679-ad71-4254-a9ca-b27a03ca8df0" />

---
## 3. Requisitos funcionales

### 3.1 Pantalla de búsqueda

- La app utiliza una pantalla llamada CitySelection en la que utiliza un buscador que va mostrando los resultados según escribe el usuario
- El usuario podrá pulsar en el botón de Usar ubicación actual y mostrará el resultado en la lista.
- Si el permiso de ubicación está denegado, se muestra un aviso con la opción "Ir a Ajustes" (`.alert` en `CitySelectionView`).

### 3.2 Cancelación de búsquedas anteriores

Si el usuario escribe otra búsqueda antes de que termine la anterior, la petición en curso se cancela y no se muestran resultados antiguos.

Implementación en `CitySelectionViewModel` (`Presentation/Representation/ViewModels/CitySelection/`), funciones `loadCitySuggestions(name:)` y `fetchCitySuggestions(name:)`:

| Paso | Qué hace |
|---|---|
| Cancelar la búsqueda anterior | `searchTask?.cancel()` cada vez que cambia el texto |
| Guardar la búsqueda nueva | `searchTask = Task { … }`, la tarea que se puede cancelar |
| Debounce de 100 ms | `try? await Task.sleep(for: searchDebounce)`: si llega otra tecla antes, el `sleep` termina al cancelarse la tarea |
| No lanzar la petición si ya se canceló | `guard !Task.isCancelled else { return }`: una búsqueda superada nunca llega a la red |
| Descartar la respuesta si llegó tarde | `… as? GeoCodingSearchWrapper, !Task.isCancelled`: aunque la red ignorara la cancelación, el resultado obsoleto no se pinta |
| Cancelación no es un error | `isCancellation(_:)` reconoce `CancellationError` y `URLError(.cancelled)`; en ese caso no se vacía la lista ni se registra un error |

El debounce de 100 ms viene de `Constants.Search.debounce` y se inyecta en el `init` del ViewModel.

Un texto vacío cancela la búsqueda en curso y vacía la lista (inicio de `loadCitySuggestions(name:)`).

### 3.3 Pantalla de detalle (llamada Dashboard)

- Al tocar una fila de `CityList` en `CitySelectionView`, se llama a `CitySelectionViewModel.didTapContinue(city:)`, que guarda la ciudad y activa la navegación.
- La navegación está en `CitySelectionView` (`navigationDestination`) y crea el Dashboard con `CitySelectionConnector.navigateToDashboard(city:country:)`.
- El Dashboard es `DashboardView` (`Presentation/Platform/Scenes/Dashboard/View/`) y muestra estos campos:
  - **temperatura, descripción y mínima/máxima**: `TemperatureView`;
  - **previsión por horas** (5 franjas): `TimeHoursView`;
  - **previsión de 5 días**: `DayForecast`.
- Los datos los carga `DashboardViewModel.loadWeather(city:country:)`, con los casos de uso de tiempo y previsión.

---

## 4. Requisitos técnicos

### 4.1 Arquitectura
El proyecto se organiza en diferentes capas, dentro de `CityWeather/`:

| Capa | Carpetas | Responsabilidad |
|---|---|---|
| **Data** | `Data/` y `Network/` | Habla con la red (`URLSession`), decodifica el JSON, implementa los repositorios y gestiona la caché y el almacenamiento local. |
| **Domain** | `Domain/` | Casos de uso (`AsyncUseCase`) y contratos de repositorio (`ModelProtocol`). No depende de SwiftUI ni de la red. |
| **Presentation** | `Presentation/Representation/` (lógica) y `Presentation/Platform/` (SwiftUI) | `Representation/`: ViewModels y factorías de casos de uso. `Platform/`: vistas, conectores de navegación y componentes. |

**Regla de dependencias:** `Presentation → Domain ← Data`. El ViewModel solo conoce casos de uso; el caso de uso solo conoce el protocolo del repositorio; el repositorio de Data implementa ese protocolo.

Ejemplo de la cadena para la búsqueda (la monta `GeoCodingServiceUseCaseFactory`):

`CitySelectionViewModel` → `GetDataSearchUseCase` → `GeoCodingServicesModelProtocol` (Domain) ← `GeoCodingServicesRepository` (Data)

**Por qué `Presentation/` tiene dos carpetas:** `Representation/` contiene la lógica de presentación (ViewModels y factorías); `Platform/` contiene lo dependiente de SwiftUI (vistas, conectores, componentes y `App`). Ambas forman la capa Presentation.

### 4.2 UI en SwiftUI
Todas las pantallas están en SwiftUI: `CityWeatherApp` (`App`, con `NavigationStack`), `CitySelectionView` y `DashboardView`. 

### 4.3 Concurrencia y asincronía

- Toda la lógica de búsqueda es `async/await`: el caso de uso (`GetDataSearchUseCase.execute()`), el repositorio (`GeoCodingServicesRepository.getDataSearch(name:)`) y el cliente de red (`NetworkDispatcher.call(endpoint:)`).

### 4.4 Caché por búsqueda con caducidad
Se ha implementado el requisito por query, caducidad de 5 minutos, devolver el cacheado sin red si es válido y renovarlo si caduca.

- **Dónde:** `GeoCodingSearchCache` (`Data/Cache/`), un `actor` con un diccionario de entradas y su fecha de guardado.
- **Tiempo de vida:** 5 minutos (`Constants.Search.cacheTimeToLive = 300` segundos).
- **Clave normalizada:** quita espacios y pasa a minúsculas, así `"Madrid"` y `" madrid "` comparten entrada.
- **Uso:** `GeoCodingServicesRepository.getDataSearch(name:)` devuelve la entrada si es válida; si no existe o ha caducado, llama a la red y guarda el resultado. Si la red falla, no se guarda nada.

¿Por qué la caché está en el repositorio y no en el ViewModel, en el caso de uso o en el APIClient? El repositorio es quien coordina las fuentes de datos (red y memoria). Domain no sabe que la caché existe y Presentation tampoco. La caché es un detalle de Data.

### 4.5 Tests
El target `CityWeatherTests` contiene los tests. Se agrupan por capa, igual que el código:

| Capa | Qué se prueba |
|---|---|
| **Domain** | Casos de uso con repositorios mockeados: pasan la ciudad buscada, devuelven el resultado y propagan los errores. |
| **Data** | Caché: acierto sin red, caducidad y refresco, clave normalizada y errores no cacheados. También los API clients. |
| **Presentation** | ViewModels: cancelación, debounce, resultados obsoletos, filtro por país, navegación y errores. Vistas: renderizado de cada estado. |

Los tests están escritos con **Swift Testing** (`@Test`, `#expect`), el framework actual de Apple. `UserDefaultsStorageTest` se mantiene en **XCTest** de forma intencionada, como ejemplo de que ambos frameworks conviven en el mismo target. Es útil en proyectos reales, donde la migración a Swift Testing suele hacerse de forma gradual.
