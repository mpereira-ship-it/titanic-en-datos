# ¿Sobrevivirías al Titanic? — GitHub Pages

Simulador didáctico para estudiantes de cuarto medio, basado en la **regresión logística y los 11 coeficientes** del archivo R original `fuente_R/model_pred.R`.

## Qué hace

- Permite modificar edad, sexo histórico registrado, clase, tamaño familiar, tarifa y puerto de embarque.
- Calcula en el navegador una probabilidad de supervivencia y permite comparar un escenario A con uno B.
- Muestra la matemática: predictor lineal `eta` y función logística.
- Muestra proporciones **observadas** (muestra de 891 registros) separadas de predicciones del **modelo**.
- Es una aplicación **100 % estática** (`index.html`, CSS y JavaScript sin dependencias externas).

**Importante:** GitHub Pages **no ejecuta R/Shiny en un servidor**. El archivo R queda publicado como referencia; los cálculos de la app los realiza JavaScript reproduciendo literalmente los coeficientes y la fórmula de R.

## 1. Probar localmente desde una terminal Ubuntu

```bash
cd ~/Descargas/titanic-github-pages
python3 -m http.server 8000
```

Después visita `http://localhost:8000` en Firefox. Ctrl+C detiene el servidor.
Puedes también abrir `index.html` directamente sin conexión a internet.

## 2. Comprobar que reproduce el modelo original

Si tienes `node` instalado:

```bash
node tests/verificar_modelo.js
```

Esta prueba compara los coeficientes con el archivo R y comprueba cuatro predicciones con los resultados de las figuras, además de otros escenarios. No reentrena el modelo.

## 3. Subir a GitHub desde Ubuntu

### Opción A: terminal guiada (GitHub CLI)

Una única vez:

```bash
sudo apt update
sudo apt install git gh

gh auth login
```

Selecciona `GitHub.com`, protocolo `HTTPS` e inicio de sesión con el navegador.

Después, situado dentro de `titanic-github-pages`:

```bash
bash publicar_github.sh
```

El script **pide confirmación antes de crear un repositorio público** llamado `titanic-en-datos`, y posteriormente intenta activar GitHub Pages. Si no puede activar Pages por API, basta hacerlo manualmente como se indica abajo.

### Opción B: comandos manuales

```bash
git init -b main
git add .
git commit -m "Publicar simulador Titanic"
gh repo create titanic-en-datos --public --source=. --remote=origin --push
```

Ahora en GitHub, entra al repositorio: `Settings → Pages → Build and deployment → Deploy from a branch → main → /(root) → Save`.

La dirección habitual será `https://TU-USUARIO.github.io/titanic-en-datos/` **una vez publicado**, donde `TU-USUARIO` es tu identificador de GitHub. Obtendrás la URL definitiva en la sección *Settings → Pages*.

### Modificar y actualizar

```bash
git add .
git commit -m "Ajustes para la charla"
git push
```

## 4. Notas científicas

- El modelo es **idéntico al original de R en sus coeficientes y codificación**: clase 1 de referencia, `female` como referencia, `embarked=C` como referencia; edad continua y `child1 = I(age < 18)`.
- Tamaño familiar `fsize=1` indica que la persona viaja sin familiares; `fsize=2..4` es la categoría *Peque*; `fsize>=5` es la categoría de referencia. En `model_pred.R`, la variable `fsize` incluye al pasajero.
- Tarifas expresadas en libras registradas para el Titanic; la interfaz limita los valores de entrada entre 0 y 200 para reproducir la interfaz R original.
- Los números **observados** son los de la presentación anterior (891 registros). No se reconstruyó el proceso de entrenamiento ni se recalculó el AUC. El AUC 0,888 citado originalmente no es una nueva validación.
- Las diferencias estimadas son asociaciones en los datos, no efectos causales. El salto en edad 18 surge por el indicador `age < 18` y no demuestra una discontinuidad real.
- Este es un recurso histórico/educativo, no un instrumento para tomar decisiones reales.

Documentación: [GitHub Pages — configurar fuente de publicación](https://docs.github.com/es/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site).
