//
//  CityWeatherApp.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 27/3/25.
//

import SwiftUI

@main
struct CityWeatherApp: App {
    @State private var lang: String = Constants.Locale.esLanguage // TODO: 01 Cambiar por dato persistente con el idioma escogido anteriormente y si no tiene poner por defecto idioma del iphone
    // TODO: 01 Crear una variable con dato persistente para la seleccion de la ciudad escogida y guardada anteriormente
    
    var body: some Scene {
        WindowGroup {
           /* NavigationStack {     // TODO: 01 Si tienes datos persistentes inicia pantalla dashboard si no lo tiene elige pantalla selecction
                MainScreenConnector().assembleModule(lang: $lang)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext) 
                    .environment(\.locale, .init(identifier: lang))
            } */
        }
    }
}

