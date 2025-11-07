# Archivos de Sonido Requeridos

Para que la aplicación funcione correctamente con sonidos, necesitas agregar los siguientes archivos de audio en esta carpeta:

## Archivos necesarios:

1. **error.mp3** - Sonido que se reproduce cuando el jugador comete un error
   - Recomendación: Un sonido corto de "error" o "buzzer"
   - Duración sugerida: 0.5-1 segundo

2. **success.mp3** - Sonido que se reproduce cuando el jugador acierta
   - Recomendación: Un sonido positivo como "ding" o "éxito"
   - Duración sugerida: 0.5-1 segundo

## Dónde obtener sonidos gratuitos:

- [Freesound.org](https://freesound.org/)
- [Zapsplat.com](https://www.zapsplat.com/)
- [Mixkit.co](https://mixkit.co/free-sound-effects/)

## Nota:

Si no agregas estos archivos, la aplicación funcionará pero sin sonidos. 
Solo habrá vibración como feedback.

## Alternativa temporal:

Puedes comentar las líneas de `playErrorSound()` y `playSuccessSound()` 
en el archivo `lib/services/feedback_service.dart` si no quieres usar sonidos por ahora.
