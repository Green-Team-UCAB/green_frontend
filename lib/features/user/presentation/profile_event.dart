abstract class ProfileEvent {}

/// Evento para cargar la información del perfil del servidor
class ProfileGetInfo extends ProfileEvent {}

/// Evento para limpiar el estado del perfil (útil al hacer logout)
class ProfileReset extends ProfileEvent {}