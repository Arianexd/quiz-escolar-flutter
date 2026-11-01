
import asyncio
import json
import logging
import os
import random
import re
import unicodedata
from typing import Literal

from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from google import genai
from google.genai import types
from pydantic import BaseModel, Field

load_dotenv()

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("cuestapp")

app = FastAPI(title="CuestApp API", version="0.3.0")

app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"http://(localhost|127\.0\.0\.1)(:\d+)?",
    allow_methods=["GET", "POST"],
    allow_headers=["Content-Type"],
)

API_KEY = os.getenv("GEMINI_API_KEY")
MODEL_NAME = os.getenv("GEMINI_MODEL", "gemini-3.1-flash-lite")

client = genai.Client(api_key=API_KEY) if API_KEY else None


class QuizRequest(BaseModel):
    posta: str = Field(min_length=3, max_length=120)
    tema: str = Field(min_length=3, max_length=2000)
    modo: Literal["practica", "simulacro"]
    dificultad: Literal["Fácil", "Intermedio", "Difícil"] = "Intermedio"
    cantidad: int = Field(default=10, ge=1, le=20)
    anteriores: list[str] = Field(default_factory=list, max_length=30)


class Question(BaseModel):
    tipo: Literal["opcion_multiple", "texto"]
    pregunta: str = Field(min_length=10)
    opciones: list[str] = Field(default_factory=list)
    correcta: int = Field(default=0, ge=0, le=3)
    respuesta_texto: str = ""
    variantes_validas: list[str] = Field(default_factory=list)
    explicacion: str = Field(min_length=10)


class QuizResponse(BaseModel):
    preguntas: list[Question]


def normalizar(texto: str) -> str:
    texto = unicodedata.normalize("NFD", texto.casefold())
    texto = "".join(
        letra for letra in texto
        if unicodedata.category(letra) != "Mn"
    )
    return " ".join(texto.split())


def build_prompt(data: QuizRequest, cantidad_texto: int) -> str:
    anteriores = json.dumps(
        data.anteriores[-30:],
        ensure_ascii=False,
    )

    return f"""
Actúa como docente de secundaria en Bolivia.
Genera EXACTAMENTE {data.cantidad} preguntas originales.

POSTA: {data.posta}
TEMAS: {data.tema}
MODO: {data.modo}
DIFICULTAD: {data.dificultad}

Genera exactamente {cantidad_texto} preguntas de tipo "texto".
Las demás deben ser de tipo "opcion_multiple".

En las preguntas de tipo "texto":
- La respuesta debe ser breve y objetivamente verificable.
- Debe existir una respuesta inequívoca.
- Incluye la respuesta canónica en respuesta_texto.
- Incluye solo variantes REALMENTE correctas en variantes_validas.
- Las variantes no son errores ortográficos.
- No uses preguntas que requieran redacciones largas,
  opiniones personales ni respuestas ambiguas.
- Si preguntas por una palabra, respeta su ortografía.
- Si preguntas por una cantidad numérica, puedes incluir
  el número y su expresión escrita como variantes válidas
  cuando tengan exactamente el mismo valor.
- opciones debe ser una lista vacía.
- correcta debe ser 0.

En las preguntas de tipo "opcion_multiple":
- Incluye exactamente cuatro opciones diferentes.
- correcta es el índice de la respuesta correcta, de 0 a 3.
- respuesta_texto debe estar vacía.
- variantes_validas debe ser una lista vacía.

Criterios de dificultad:
Fácil: definiciones y reconocimiento.
Intermedio: comprensión y aplicación.
Difícil: análisis y razonamiento.

Reglas generales:
- Respeta el contenido de la posta y del tema.
- En simulacro cubre distintos subtemas.
- No repitas preguntas ni formulaciones casi idénticas.
- Incluye una explicación clara en todas las preguntas.
- No inventes hechos históricos o científicos.
- No generes respuestas ambiguas.
- Devuelve el contenido según el esquema estructurado.

Evita estas preguntas anteriores:
{anteriores}
"""


def validar(quiz: QuizResponse, data: QuizRequest, cantidad_texto: int):
    if len(quiz.preguntas) != data.cantidad:
        raise ValueError("Cantidad de preguntas incorrecta")

    if sum(p.tipo == "texto" for p in quiz.preguntas) != cantidad_texto:
        raise ValueError("Mezcla de tipos de preguntas incorrecta")

    vistas = set()

    for p in quiz.preguntas:
        clave = normalizar(p.pregunta)

        if clave in vistas:
            raise ValueError("Preguntas duplicadas")

        vistas.add(clave)

        if p.tipo == "opcion_multiple":
            if len(p.opciones) != 4:
                raise ValueError("Faltan opciones")
            if len({normalizar(x) for x in p.opciones}) != 4:
                raise ValueError("Opciones duplicadas")
            if not all(x.strip() for x in p.opciones):
                raise ValueError("Hay opciones vacías")
        else:
            if not p.respuesta_texto.strip():
                raise ValueError("Falta la respuesta escrita")
            if p.opciones:
                raise ValueError("Pregunta escrita tiene opciones")
            if not all(v.strip() for v in p.variantes_validas):
                raise ValueError("Variante vacía")


def generate_quiz(data: QuizRequest) -> QuizResponse:
    if client is None:
        raise ValueError("Falta GEMINI_API_KEY")

    # Aproximadamente la mitad será de respuesta escrita.
    # Con una sola pregunta, elegimos el tipo al azar.
    cantidad_texto = (
        random.randint(0, 1)
        if data.cantidad == 1
        else data.cantidad // 2
    )

    result = client.models.generate_content(
        model=MODEL_NAME,
        contents=build_prompt(data, cantidad_texto),
        config=types.GenerateContentConfig(
            response_mime_type="application/json",
            response_schema=QuizResponse,
            temperature=0.85,
        ),
    )

    if not result.text:
        raise ValueError("Gemini devolvió una respuesta vacía")

    quiz = QuizResponse.model_validate_json(result.text)
    validar(quiz, data, cantidad_texto)

    random.shuffle(quiz.preguntas)
    return quiz


@app.get("/health")
def health():
    return {
        "status": "ok",
        "gemini_configured": client is not None,
    }


@app.post("/api/quiz/generar", response_model=QuizResponse)
async def generar_preguntas(data: QuizRequest):
    if client is None:
        raise HTTPException(
            status_code=500,
            detail="Falta configurar GEMINI_API_KEY",
        )

    try:
        return await asyncio.to_thread(generate_quiz, data)
    except Exception as error:
        logger.exception("Error generando preguntas")
        raise HTTPException(
            status_code=502,
            detail=(
                "No se pudieron generar preguntas válidas. "
                "Revisa la terminal de FastAPI."
            ),
        ) from error

from voice_routes import router as voice_router
app.include_router(voice_router)