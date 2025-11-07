-- ============================================
-- SETUP COMPLETO PARA SUPABASE
-- Crossword Generator App
-- ============================================

-- Paso 1: Crear tabla de categorías
CREATE TABLE IF NOT EXISTS categories (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Paso 2: Crear tabla de palabras
CREATE TABLE IF NOT EXISTS words (
  id BIGSERIAL PRIMARY KEY,
  word TEXT NOT NULL,
  category TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear índice para mejorar búsquedas por categoría
CREATE INDEX IF NOT EXISTS idx_words_category ON words(category);

-- Paso 3: Crear tabla de puntuaciones
CREATE TABLE IF NOT EXISTS scores (
  id BIGSERIAL PRIMARY KEY,
  player_name TEXT NOT NULL,
  score INTEGER NOT NULL,
  time INTEGER NOT NULL,
  category TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear índice para ordenar por mejores scores
CREATE INDEX IF NOT EXISTS idx_scores_score ON scores(score DESC);

-- ============================================
-- CONFIGURAR PERMISOS (Row Level Security)
-- ============================================

-- Habilitar RLS en todas las tablas
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE words ENABLE ROW LEVEL SECURITY;
ALTER TABLE scores ENABLE ROW LEVEL SECURITY;

-- Eliminar políticas existentes si las hay
DROP POLICY IF EXISTS "Allow public read access" ON categories;
DROP POLICY IF EXISTS "Allow public read access" ON words;
DROP POLICY IF EXISTS "Allow public insert" ON scores;
DROP POLICY IF EXISTS "Allow public read scores" ON scores;

-- Permitir lectura pública para categories
CREATE POLICY "Allow public read access" ON categories
  FOR SELECT USING (true);

-- Permitir lectura pública para words
CREATE POLICY "Allow public read access" ON words
  FOR SELECT USING (true);

-- Permitir insertar scores
CREATE POLICY "Allow public insert" ON scores
  FOR INSERT WITH CHECK (true);

-- Permitir lectura de scores
CREATE POLICY "Allow public read scores" ON scores
  FOR SELECT USING (true);

-- ============================================
-- DATOS DE EJEMPLO
-- ============================================

-- Insertar categorías
INSERT INTO categories (name) VALUES
  ('Animales'),
  ('Frutas'),
  ('Paises'),
  ('Deportes'),
  ('Colores'),
  ('Ciudades')
ON CONFLICT (name) DO NOTHING;

-- Palabras de Animales
INSERT INTO words (word, category) VALUES
  ('perro', 'Animales'),
  ('gato', 'Animales'),
  ('leon', 'Animales'),
  ('tigre', 'Animales'),
  ('elefante', 'Animales'),
  ('jirafa', 'Animales'),
  ('mono', 'Animales'),
  ('oso', 'Animales'),
  ('caballo', 'Animales'),
  ('vaca', 'Animales'),
  ('pato', 'Animales'),
  ('conejo', 'Animales'),
  ('tortuga', 'Animales'),
  ('delfin', 'Animales'),
  ('ballena', 'Animales');

-- Palabras de Frutas
INSERT INTO words (word, category) VALUES
  ('manzana', 'Frutas'),
  ('pera', 'Frutas'),
  ('uva', 'Frutas'),
  ('sandia', 'Frutas'),
  ('melon', 'Frutas'),
  ('fresa', 'Frutas'),
  ('platano', 'Frutas'),
  ('naranja', 'Frutas'),
  ('limon', 'Frutas'),
  ('mango', 'Frutas'),
  ('piña', 'Frutas'),
  ('durazno', 'Frutas'),
  ('cereza', 'Frutas'),
  ('kiwi', 'Frutas');

-- Palabras de Países
INSERT INTO words (word, category) VALUES
  ('mexico', 'Paises'),
  ('canada', 'Paises'),
  ('brasil', 'Paises'),
  ('argentina', 'Paises'),
  ('chile', 'Paises'),
  ('peru', 'Paises'),
  ('colombia', 'Paises'),
  ('españa', 'Paises'),
  ('francia', 'Paises'),
  ('italia', 'Paises'),
  ('alemania', 'Paises'),
  ('japon', 'Paises'),
  ('china', 'Paises'),
  ('india', 'Paises');

-- Palabras de Deportes
INSERT INTO words (word, category) VALUES
  ('futbol', 'Deportes'),
  ('basquetbol', 'Deportes'),
  ('tenis', 'Deportes'),
  ('natacion', 'Deportes'),
  ('atletismo', 'Deportes'),
  ('boxeo', 'Deportes'),
  ('ciclismo', 'Deportes'),
  ('golf', 'Deportes'),
  ('voleibol', 'Deportes'),
  ('beisbol', 'Deportes'),
  ('rugby', 'Deportes'),
  ('karate', 'Deportes');

-- Palabras de Colores
INSERT INTO words (word, category) VALUES
  ('rojo', 'Colores'),
  ('azul', 'Colores'),
  ('verde', 'Colores'),
  ('amarillo', 'Colores'),
  ('naranja', 'Colores'),
  ('morado', 'Colores'),
  ('rosa', 'Colores'),
  ('negro', 'Colores'),
  ('blanco', 'Colores'),
  ('gris', 'Colores'),
  ('cafe', 'Colores'),
  ('violeta', 'Colores');

-- Palabras de Ciudades
INSERT INTO words (word, category) VALUES
  ('paris', 'Ciudades'),
  ('londres', 'Ciudades'),
  ('tokyo', 'Ciudades'),
  ('nueva', 'Ciudades'),
  ('madrid', 'Ciudades'),
  ('roma', 'Ciudades'),
  ('berlin', 'Ciudades'),
  ('moscu', 'Ciudades'),
  ('dubai', 'Ciudades'),
  ('sidney', 'Ciudades'),
  ('miami', 'Ciudades'),
  ('barcelona', 'Ciudades');

-- ============================================
-- VERIFICACIÓN
-- ============================================

-- Ver cuántas categorías hay
SELECT 'Categorias creadas:' as info, COUNT(*) as total FROM categories;

-- Ver cuántas palabras hay por categoría
SELECT category, COUNT(*) as total_words 
FROM words 
GROUP BY category 
ORDER BY category;

-- ============================================
-- ¡LISTO! Tu base de datos está configurada
-- ============================================
