/* ==========================================================================
   PoliMusic - app.js
   --------------------------------------------------------------------------
   JavaScript para la pgina de canciones (songs.asp)
   
   Funcionalidades:
   1. Reproductor de audio fijo (HTML5 <audio>)
   2. Botn Play por fila: carga la cancin y la reproduce
   3. Muestra qu cancin est sonando (resalta la fila)
   4. Incrementa PLAYS con fetch() a play_count.asp?id=...
   5. Toggle de formularios (Crear / Editar)
   6. Confirmacin de eliminacin con JavaScript
   ========================================================================== */

(function() {
    'use strict';

    // --- Referencias a elementos del DOM ---
    const audioPlayer = document.getElementById('audioPlayer');
    const currentSongTitle = document.getElementById('currentSongTitle');
    const playerBar = document.getElementById('playerBar');
    let currentRow = null; // Fila que est sonando actualmente

    // ========================================================================
    // 1. REPRODUCIR CANCIN
    //    Llamada desde el botn Play de cada fila en songs.asp
    // ========================================================================

    /**
     * Carga una cancin en el reproductor y la reproduce.
     * @param {number} songId    - ID de la cancin en la BD
     * @param {string} songPath  - Ruta relativa del archivo (ej: "songFiles/track.mp3")
     * @param {string} songName  - Nombre de la cancin para mostrar
     */
    window.playSong = function(songId, songPath, songName) {

        // --- Quitar el resaltado de la fila anterior ---
        if (currentRow) {
            currentRow.classList.remove('now-playing');
            const prevBtn = currentRow.querySelector('.btn-play');
            if (prevBtn) {
                prevBtn.classList.remove('playing');
                prevBtn.innerHTML = '<span class="play-icon">&#9654;</span> Play';
            }
        }

        // --- Encontrar y resaltar la fila actual ---
        currentRow = document.querySelector('tr[data-song-id="' + songId + '"]');
        if (currentRow) {
            currentRow.classList.add('now-playing');
            const playBtn = currentRow.querySelector('.btn-play');
            if (playBtn) {
                playBtn.classList.add('playing');
                playBtn.innerHTML = '<span class="play-icon">&#9654;</span> Sonando...';
            }
        }

        // --- Cargar y reproducir el audio ---
        audioPlayer.src = songPath;
        audioPlayer.load();
        audioPlayer.play().catch(function(err) {
            console.warn('No se pudo reproducir automticamente:', err);
        });

        // --- Actualizar el texto del reproductor ---
        currentSongTitle.textContent = songName;
        playerBar.style.display = 'block';

        // --- Incrementar PLAYS en la BD usando fetch() ---
        incrementPlayCount(songId);
    };

    // ========================================================================
    // 2. INCREMENTAR PLAYS EN LA BASE DE DATOS
    //    Usa fetch() para llamar play_count.asp?id=... sin recargar la pgina
    // ========================================================================

    /**
     * Llama a play_count.asp para incrementar el contador de reproducciones.
     * @param {number} songId - ID de la cancin
     */
    function incrementPlayCount(songId) {
        // Construir la URL con el query parameter
        const url = 'play_count.asp?id=' + encodeURIComponent(songId);

        // fetch() enva una peticin HTTP y devuelve una promesa
        fetch(url)
            .then(function(response) {
                // Verificar que la respuesta sea OK (status 200-299)
                if (!response.ok) {
                    throw new Error('HTTP ' + response.status);
                }
                // Parsear la respuesta como JSON
                return response.json();
            })
            .then(function(data) {
                // data = { "status": "ok", "plays": 42 }
                if (data.status === 'ok') {
                    // Actualizar el nmero en la tabla sin recargar
                    const playsSpan = document.getElementById('plays-' + songId);
                    if (playsSpan) {
                        // Animacin simple: cambiar el color brevemente
                        playsSpan.style.transition = 'all 0.3s ease';
                        playsSpan.style.color = 'var(--pm-success)';
                        playsSpan.style.transform = 'scale(1.2)';
                        playsSpan.textContent = data.plays;

                        // Volver al estado normal despus de 600ms
                        setTimeout(function() {
                            playsSpan.style.color = '';
                            playsSpan.style.transform = '';
                        }, 600);
                    }
                }
            })
            .catch(function(err) {
                // Si falla el fetch, no rompemos la aplicacin, solo logueamos
                console.error('Error al incrementar PLAYS:', err);
            });
    }

    // ========================================================================
    // 3. TOGGLE DE FORMULARIOS (Crear cancin)
    // ========================================================================

    /**
     * Muestra u oculta un formulario modal por su ID.
     * @param {string} formId - ID del elemento a togglear
     */
    window.toggleForm = function(formId) {
        const el = document.getElementById(formId);
        if (!el) return;

        if (el.style.display === 'none' || el.style.display === '') {
            el.style.display = 'block';
        } else {
            el.style.display = 'none';
        }
    };

    // ========================================================================
    // 4. CONFIRMAR ELIMINACIN
    // ========================================================================

    /**
     * Muestra un dilogo de confirmacin antes de eliminar una cancin.
     * Si el usuario confirma, redirige a song_delete.asp?id=...
     * @param {number} songId   - ID de la cancin a eliminar
     * @param {string} songName - Nombre de la cancin (para el mensaje)
     */
    window.confirmDelete = function(songId, songName) {
        const mensaje =
            'Ests seguro de que deseas eliminar la cancin?\n\n' +
            '"' + songName + '"\n\n' +
            'Esta accin no se puede deshacer.';

        if (confirm(mensaje)) {
            window.location.href = 'song_delete.asp?id=' + songId;
        }
    };

    // ========================================================================
    // 5. EVENTO: cuando termina la cancin
    // ========================================================================

    if (audioPlayer) {
        audioPlayer.addEventListener('ended', function() {
            // Restaurar el botn de Play
            if (currentRow) {
                const playBtn = currentRow.querySelector('.btn-play');
                if (playBtn) {
                    playBtn.classList.remove('playing');
                    playBtn.innerHTML = '<span class="play-icon">&#9654;</span> Play';
                }
            }
            currentSongTitle.textContent = 'Selecciona una cancin';
        });
    }

    // ========================================================================
    // 6. EVENTO: cuando se carga la pgina
    // ========================================================================

    document.addEventListener('DOMContentLoaded', function() {
        // Asegurar que el reproductor est visible pero sin cancin cargada
        if (playerBar) {
            playerBar.style.display = 'block';
        }

        // Si hay un formulario de edicin visible, hacer scroll hacia l
        const editForm = document.getElementById('form-edit');
        if (editForm && editForm.style.display !== 'none') {
            editForm.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }
    });

})();
