# Ticketera Cambio

App Flutter para casa de cambio: calculadora + ticket digital + impresión en ticketera térmica Bluetooth + historial local en SQLite.

## Qué incluye (v1)

- Calculadora tipo mockup (÷ × − +, =, C)
- Ticket en vivo con toggle Compra/Venta y selector de monedas
- Impresión mediante el sistema nativo de Android (`printing` + PDF): al presionar "Imprimir" se abre el diálogo estándar de impresión, donde aparece tu ticketera (si configuraste RawBT) junto con "Guardar como PDF" y cualquier otra impresora disponible
- Botón "Compartir": genera el PDF del ticket y abre el selector de apps directo (WhatsApp, Drive, etc.), sin pasar por el diálogo de impresión
- Historial diario guardado en SQLite local (offline, sin depender de internet)
- Ajustes: nombre del negocio, ubicación, teléfono, monedas por defecto, guía para configurar la impresora

No incluido todavía (v2 sugerida): sincronizar historial a tu VPS, campo de cliente en la UI, personalizar el diseño del PDF con logo.

### Por qué no se usa Bluetooth directo

Las ticketeras térmicas genéricas no traen un driver de Android registrado, así que no aparecen en el diálogo nativo de impresión por sí solas. La solución estándar es usar **RawBT** (app gratuita) como puente: configuras tu ticketera ahí una sola vez, y desde ese momento cualquier app que imprima con el sistema estándar de Android (incluida esta) la va a poder usar sin volver a configurarla. Los pasos exactos están dentro de la app en Ajustes → "Cómo configurar tu impresora".

## Cómo compilar el APK (sin instalar nada en tu PC)

1. Crea un repositorio nuevo en tu GitHub (`fate-kiritsugu`), por ejemplo `ticketera-cambio`.
2. Sube todo el contenido de esta carpeta a la rama `main`:
   ```bash
   cd ticketera_cambio
   git init
   git add .
   git commit -m "Proyecto inicial ticketera cambio"
   git branch -M main
   git remote add origin https://github.com/fate-kiritsugu/ticketera-cambio.git
   git push -u origin main
   ```
3. En GitHub, ve a la pestaña **Actions** de tu repo. El workflow "Build APK" corre automáticamente en cada push a `main` (o dispáralo manualmente con "Run workflow").
4. Cuando termine (~5-8 min), el APK queda disponible en dos lugares:
   - **Releases** (pestaña derecha del repo) → descarga directa desde el celular
   - **Actions → el run correspondiente → Artifacts** (requiere sesión de GitHub)

## Cómo instalar el APK en el celular

1. Descarga el `.apk` desde el Release de GitHub directamente en el navegador del celular.
2. Android pedirá permitir "instalar apps de orígenes desconocidos" para el navegador — actívalo solo para esa instalación.
3. Abre el APK descargado para instalarlo.

## Cómo emparejar la ticketera

1. Empareja la impresora térmica desde **Ajustes de Android → Bluetooth** (fuera de la app), como cualquier dispositivo Bluetooth.
2. Abre la app → **Ajustes → Configurar impresora Bluetooth**.
3. Selecciona tu impresora de la lista de emparejados y presiona "Imprimir prueba" para confirmar que imprime.

## Estructura del proyecto

```
lib/
  models/operation.dart       -> modelo de una operación de cambio
  db/database_helper.dart     -> SQLite local (tabla operations)
  services/settings_service.dart  -> datos del negocio guardados localmente
  services/printer_service.dart   -> lógica de impresión Bluetooth ESC/POS
  screens/home_screen.dart    -> calculadora + ticket + botón imprimir
  screens/history_screen.dart -> historial por día con totales
  screens/settings_screen.dart -> datos del negocio + acceso a impresora
  screens/printer_screen.dart -> emparejar/probar impresora
  widgets/ticket_preview.dart -> card visual del ticket
android_template/AndroidManifest.xml -> permisos de Bluetooth (se copia en el build)
.github/workflows/build_apk.yml      -> compila el APK automáticamente
```

## Notas técnicas

- La carpeta `android/` no está en el repo a propósito: el workflow la genera con `flutter create` en cada build para evitar arrastrar archivos binarios de Gradle. Si más adelante quieres generarla localmente (con Android Studio instalado), corre `flutter create --platforms=android --org com.nicool .` una sola vez y ya no hace falta el paso automático.
- El paquete de impresión usado es `blue_thermal_printer`, pensado para impresoras Bluetooth Classic (SPP) compatibles con ESC/POS — la gran mayoría de ticketeras térmicas chinas/genéricas funcionan así.
- Si tu ticketera es Bluetooth Low Energy (BLE) en vez de Classic, avísame: se necesita un paquete distinto (`esc_pos_printer` sobre BLE) y cambia la lógica de conexión.
