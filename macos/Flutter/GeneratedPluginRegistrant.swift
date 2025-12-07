//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation
import path_provider_foundation // Mantenido de 'develop'
import shared_preferences_foundation // Mantenido de ambas

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  // Registro de 'develop'
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  
  // Registro de ambas
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
}
