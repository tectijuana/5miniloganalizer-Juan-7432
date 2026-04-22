/*
Autor: Juan David Fernández Hernández
Curso: Lenguajes de Interfaz
Práctica: Mini Cloud Log Analyzer (Bash + ARM64 + GNU Make)
Fecha: 22 de abril de 2026
Descripción: Lee códigos HTTP desde stdin (uno por línea), clasifica 2xx/4xx/5xx
             y muestra un reporte en español usando únicamente syscalls Linux.
*/

/*
PSEUDOCÓDIGO (guía didáctica)
1) Inicializar contadores en 0: exitos_2xx, errores_4xx, errores_5xx.
2) Mientras haya bytes por leer en stdin:
   2.1) Leer un bloque con syscall read.
   2.2) Recorrer byte por byte.
   2.3) Si el byte es dígito, acumular numero_actual = numero_actual * 10 + dígito.
   2.4) Si el byte es '\n', clasificar numero_actual y reiniciar acumulador.
3) Si el flujo termina sin '\n' final y hay número pendiente, clasificarlo.
4) Imprimir resultados en español con syscall write.
5) Salir con código 0.

TODO (extensión para estudiantes):
- Agregar manejo de códigos no válidos y contarlos.
- Implementar variantes B, C, D y E en ramas separadas.
- Mostrar porcentaje de éxito respecto al total.
*/

.equ SYS_read,   63
.equ SYS_write,  64
.equ SYS_exit,   93
.equ STDIN_FD,    0
.equ STDOUT_FD,   1

.section .bss
    .align 4
buffer:         .skip 4096
num_buf:        .skip 32      // Buffer para imprimir enteros en texto
counts: .skip 2400   // codigo en http que indica veces que aparece valor

.section .data
msg_titulo:         .asciz "=== Mini Cloud Log Analyzer ===\n"
msg_resultado:      .asciz "Codigo mas frecuente: "
msg_fin_linea:      .asciz "\n"

.section .text
.global _start

_start:

    // Estado del parser
    mov x22, #0                  // numero_actual
    mov x23, #0                  // tiene_digitos (0/1)

leer_bloque:
    // read(STDIN_FD, buffer, 4096)
    mov x0, #STDIN_FD
    adrp x1, buffer
    add x1, x1, :lo12:buffer
    mov x2, #4096
    mov x8, #SYS_read
    svc #0

    // x0 = bytes leídos
    cmp x0, #0
    beq fin_lectura               // EOF
    blt salida_error              // error de lectura

    mov x24, #0                   // índice i = 0
    mov x25, x0                   // total bytes en bloque

procesar_byte:
    cmp x24, x25
    b.ge leer_bloque

    adrp x1, buffer
    add x1, x1, :lo12:buffer
    ldrb w26, [x1, x24]
    add x24, x24, #1

    // Si es salto de línea, clasificar número actual
    cmp w26, #10                  // '\n'
    b.eq fin_numero

    // Si es dígito ('0'..'9'), acumular
    cmp w26, #'0'
    b.lt procesar_byte
    cmp w26, #'9'
    b.gt procesar_byte

    // numero_actual = numero_actual * 10 + (byte - '0')
    mov x27, #10
    mul x22, x22, x27
    sub w26, w26, #'0'
    uxtw x26, w26
    add x22, x22, x26
    mov x23, #1
    b procesar_byte

fin_numero:
    // Solo clasificar si efectivamente hubo al menos un dígito
    cbz x23, reiniciar_numero

    mov x0, x22
    bl incrementar_contador

reiniciar_numero:
    mov x22, #0
    mov x23, #0
    b procesar_byte

fin_lectura:
    // EOF con número pendiente (sin '\n' final)
    cbz x23, imprimir_reporte
    mov x0, x22
    bl incrementar_contador

imprimir_reporte:
    // Encabezado
    adrp x0, msg_titulo
    add x0, x0, :lo12:msg_titulo
    bl write_cstr

    // Mensaje
    adrp x0, msg_resultado
    add x0, x0, :lo12:msg_resultado
    bl write_cstr

    // Buscar máximo
    bl buscar_max
    bl print_uint

    // Salto de línea
    adrp x0, msg_fin_linea
    add x0, x0, :lo12:msg_fin_linea
    bl write_cstr

salida_ok:
    mov x0, #0
    mov x8, #SYS_exit
    svc #0

salida_error:
    mov x0, #1
    mov x8, #SYS_exit
    svc #0

// -----------------------------------------------------------------------------
// Función encargada de incremento de contador y recuento
// incrementar_contador(x0 = codigo_http)
// -----------------------------------------------------------------------------
incrementar_contador:
    cmp x0, #599
    b.gt fin_inc

    adrp x1, counts
    add x1, x1, :lo12:counts

    lsl x2, x0, #2
    add x1, x1, x2

    ldr w3, [x1]
    add w3, w3, #1
    str w3, [x1]

fin_inc:
    ret

// -----------------------------------------------------------------------------
// buscar_max()
// retorna x0 = código más frecuente
// -----------------------------------------------------------------------------
buscar_max:
    mov x1, #0          // i
    mov x2, #0          // max_count
    mov x3, #0          // max_code

    adrp x4, counts
    add x4, x4, :lo12:counts

loop_max:
    cmp x1, #600
    b.ge fin_max

    lsl x5, x1, #2
    add x6, x4, x5

    ldr w7, [x6]

    cmp x7, x2
    b.le siguiente

    mov x2, x7
    mov x3, x1

siguiente:
    add x1, x1, #1
    b loop_max

fin_max:
    mov x0, x3
    ret

// -----------------------------------------------------------------------------
// write_cstr
// -----------------------------------------------------------------------------
write_cstr:
    mov x9, x0
    mov x10, #0

wc_len_loop:
    ldrb w11, [x9, x10]
    cbz w11, wc_len_done
    add x10, x10, #1
    b wc_len_loop

wc_len_done:
    mov x1, x9
    mov x2, x10
    mov x0, #STDOUT_FD
    mov x8, #SYS_write
    svc #0
    ret

// -----------------------------------------------------------------------------
// print_uint
// -----------------------------------------------------------------------------
print_uint:
    cbnz x0, pu_convertir

    adrp x1, num_buf
    add x1, x1, :lo12:num_buf
    mov w2, #'0'
    strb w2, [x1]

    mov x0, #STDOUT_FD
    mov x2, #1
    mov x8, #SYS_write
    svc #0
    ret

pu_convertir:
    adrp x12, num_buf
    add x12, x12, :lo12:num_buf
    add x12, x12, #31

    mov w13, #0
    strb w13, [x12]

    mov x14, #10
    mov x15, #0

pu_loop:
    udiv x16, x0, x14
    msub x17, x16, x14, x0
    add x17, x17, #'0'

    sub x12, x12, #1
    strb w17, [x12]
    add x15, x15, #1

    mov x0, x16
    cbnz x0, pu_loop

    mov x1, x12
    mov x2, x15
    mov x0, #STDOUT_FD
    mov x8, #SYS_write
    svc #0
    ret
