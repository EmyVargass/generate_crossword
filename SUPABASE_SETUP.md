# Configuración de Supabase para Crossword Generator

## Tablas necesarias en Supabase

Para que la aplicación funcione correctamente, necesitas crear las siguientes tablas en tu base de datos de Supabase:

### 1. Tabla `categories` (Categorías)

```sql
CREATE TABLE categories (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Datos de ejemplo
INSERT INTO categories (name) VALUES
  ('Animales'),
  ('Frutas'),
  ('Países'),
  ('Deportes'),
  ('Colores'),
  ('Ciudades'),
  ('Comida');
```

### 2. Tabla `words` (Palabras)

```sql
CREATE TABLE words (
  id BIGSERIAL PRIMARY KEY,
  word TEXT NOT NULL,
  category TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  FOREIGN KEY (category) REFERENCES categories(name) ON DELETE CASCADE
);

-- Índice para mejorar búsquedas
CREATE INDEX idx_words_category ON words(category);

-- Datos de ejemplo para categoría "Animales"
INSERT INTO words (word, category) VALUES
  ('perro', 'Animales'),
  ('gato', 'Animales'),
  ('leon', 'Animales'),
  ('tigre', 'Animales'),
  ('elefante', 'Animales'),
  ('jirafa', 'Animales'),
  ('mono', 'Animales'),
  ('oso', 'Animales');

-- Datos de ejemplo para categoría "Frutas"
INSERT INTO words (word, category) VALUES
  ('manzana', 'Frutas'),
  ('pera', 'Frutas'),
  ('uva', 'Frutas'),
  ('sandia', 'Frutas'),
  ('melon', 'Frutas'),
  ('fresa', 'Frutas'),
  ('platano', 'Frutas');
```

### 3. Tabla `scores` (Puntuaciones)

```sql
CREATE TABLE scores (
  id BIGSERIAL PRIMARY KEY,
  player_name TEXT NOT NULL,
  score INTEGER NOT NULL,
  time INTEGER NOT NULL,
  category TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índice para ordenar por mejores scores
CREATE INDEX idx_scores_score ON scores(score DESC);
```

## Configuración de Row Level Security (RLS)

Para permitir que la app acceda a los datos, configura las políticas RLS:

```sql
-- Habilitar RLS
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE words ENABLE ROW LEVEL SECURITY;
ALTER TABLE scores ENABLE ROW LEVEL SECURITY;

-- Permitir lectura pública para categories
CREATE POLICY "Allow public read access" ON categories
  FOR SELECT USING (true);

-- Permitir lectura pública para words
CREATE POLICY "Allow public read access" ON words
  FOR SELECT USING (true);

-- Permitir insertar scores (pero no leer ni modificar)
CREATE POLICY "Allow public insert" ON scores
  FOR INSERT WITH CHECK (true);

-- Permitir lectura de scores ordenados
CREATE POLICY "Allow public read scores" ON scores
  FOR SELECT USING (true);
```

## Verificación

Para verificar que todo está configurado correctamente:

1. Ve a tu dashboard de Supabase
2. Navega a la sección "Table Editor"
3. Verifica que las tablas `categories`, `words` y `scores` existan
4. Inserta algunos datos de prueba usando el editor SQL
5. Prueba la aplicación

## Notas Importantes

- Todas las palabras deben estar en minúsculas
- Las palabras solo deben contener letras (a-z), sin acentos ni caracteres especiales
- La categoría en la tabla `words` debe coincidir exactamente con el nombre en `categories`
- El campo `time` en `scores` representa segundos

## Agregar más palabras

Puedes agregar más palabras usando SQL:

```sql
INSERT INTO words (word, category) VALUES
  ('palabra1', 'NombreCategoria'),
  ('palabra2', 'NombreCategoria'),
  ('palabra3', 'NombreCategoria');
```

O importar desde CSV en el dashboard de Supabase.
