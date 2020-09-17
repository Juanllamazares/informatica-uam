;**************************************************************************
; PRACTICA 2, EJERCICIO B -> TOMAS HIGUERA VISO Y GUILLERMO HOYO BRAVO, PAREJA 1
;**************************************************************************
; DEFINICION DEL SEGMENTO DE DATOS
	DATOS SEGMENT
		cadena_salir db "SALIENDO DEL PROGRAMA :)",'$'
		cadena_error db "ERROR!!",'$'
		tabulador db "	",'$'
		espacio db "   ",'$'
		intro db 13,10,'$'
		input db "INPUT:  ",'$'
		output db "OUTPUT: ",'$'
		barra db " | ",'$'
		cabecera db "		| P1| P2| D1| P4| D2| D3| D4|",'$'
		words db "WORD   ",'$'
		computation db "COMPUTATION: ",'$'
		p1 db "P1     ",'$'
		p2 db "P2     ",'$'
		p3 db "P3     ",'$'
		divisor db 2
		generacion db 1,0,0,0,1,1,0,0,1,0,0,1,0,1,0,0,1,0,0,1,1,0,0,0,1,1,1,1
		vector db 6 dup (0)
		resultado db ?
	DATOS ENDS
;**************************************************************************
; DEFINICION DEL SEGMENTO DE PILA
	PILA SEGMENT STACK "STACK"
		DB 40H DUP (0) ;ejemplo de inicialización, 64 bytes inicializados a 0
	PILA ENDS
;**************************************************************************
; DEFINICION DEL SEGMENTO EXTRA
	EXTRA SEGMENT
		RESULT DW 0,0 ;ejemplo de inicialización. 2 PALABRAS (4 BYTES)
	EXTRA ENDS
;************************************************************************** 
; DEFINICION DEL SEGMENTO DE CODIGO
	CODE SEGMENT
		ASSUME CS: CODE, DS: DATOS, ES: EXTRA, SS: PILA
; COMIENZO DEL PROCEDIMIENTO PRINCIPAL
INICIO PROC
; INICIALIZA LOS REGISTROS DE SEGMENTO CON SU VALOR
	MOV AX, DATOS
	MOV DS, AX
	MOV AX, PILA
	MOV SS, AX
	MOV AX, EXTRA
	MOV ES, AX
	MOV SP, 64 ; CARGA EL PUNTERO DE PILA CON EL VALOR MAS ALTO
	; UTILIZAREMOS EL INDICE DI PARA RECORRER EL VECTOR DE UNA DIMENSION
	MOV DI,0
	; UTILIZAREMOS EL INDICE SI PARA RECORRER LA MATRIZ
	MOV SI,0
; FIN DE LAS INICIALIZACIONES
	
; COMIENZO DEL PROGRAMA
	; EN ESTA RUTINA LEEREMOS POR TECLADO EL NUMERO Y LO TRANSFORMAREMOS A BINARIO
	rutina_lectura_transformacion:
		; LLAMAMOS A LA FUNCION DE LECTURA DE TECLADO
		CALL lectura_teclado
		; A CONTINUACION GUARDAMOS EL NUMERO CORRECTAMENTE EN DL PARA DESPUES TRANSFORMARLO A BINARIO
		CALL comprobacion_lectura
		; TRANSFORMAMOS EL NUMERO A DECIMAL Y LO GUARDAMOS EN NUESTRA VARIABLE VECTOR
		CALL transformacion_binario
	; EN ESTA RUTINA SE CALCULARA EL RESULTADO DE LA MULTIPLICACION, ASI COMO EL MODULO 2 DE LA MISMA
	rutina_multiplicacion:
		; LLAMAMOS A LA FUNCION MULTIPLICACION
		CALL multiplicacion
	; EN ESTA RUTINA SE COLOCARAN LOS BITS DE PARIDAD Y SE IMPRIMIRAN LOS RESULTADOS CORRECTAMENTE POR PANTALLA
	rutina_imprimir:
		; LLAMAMOS A LA FUNCION PARA COLOCAR BITS DE PARIDAD
		CALL colocacion_bits_paridad
		; LLAMAMOS A LA FUNCION PARA IMPRIMIR EL VECTOR
		CALL imprimir_vector
		; LLAMAMOS A LA FUNCION PARA IMPRIMIR UN SALTO DE LINEA
		CALL imprimir_salto_linea
		; LLAMAMOS A LA FUNCION PARA IMPRIMIR EL VECTOR RESULTANTE
		CALL imprimir_resultado
		; LLAMAMOS A LA FUNCION PARA IMPRIMIR UN SALTO DE LINEA
		CALL imprimir_salto_linea
		; LLAMAMOS A LA FUNCION PARA IMPRIMIR LA TABLA FINAL RESULTANTE
		CALL imprimir_tabla
		; SALTAMOS AL FINAL DEL PROGRAMA
		JMP fin
		
	;************************************************************************************************
	;*****************************FUNCIONES UTILIZADAS***********************************************
	;************************************************************************************************
	
	; FUNCION QUE REALIZA LA MULTIPLICACION DE UN VECTOR DE TAMANIO 4 POR UNA MATRIZ DE TAMANIO 4X7
	multiplicacion PROC
		; INICIALIZAMOS SI A 0 PARA RECORRER LA MATRIZ CORRECTAMENTE
		MOV SI, 0
		bucle8:
			; BX SERA LA VARIABLE QUE UTILIZAREMOS PARA RECORRER LAS FILAS, LA AUMENTAREMOS 7 CUANDO QUERAMOS MOVERNOS A LA SIGUIENTE FILA
			; INCIALIZAMOS BX A 0 PARA RECORRER DE NUEVO LA COLUMA DE LA MATRIZ
			MOV BX, 0
			; INICIALIZAMOS DI A 0 PARA RECORRER DE NUEVO EL VECTOR
			MOV DI, 0
			; DX SERA LA VARIABLE EN LA QUE GUARDAREMOS EL RESULTADO DE LA MULTIPLICACION PARA GUARDAR EN NUESTRO VECTOR
			; INCIALIZAMOS DX A 0 PARA GUARDAR LA SUMA DE LAS MULTIPLICACIONES DE NUEVO
			MOV DX, 0
			; LLAMAMOS A LA FUNCION MULTIPLICACION_COLUMNA PARA MULTIPLICAR UNA COLUMNA POR EL VECTOR
			CALL multiplicacion_columna
			; GUARDAMOS EL RESULTADO DE LA SUMA EN AX
			MOV AX, DX
			; DIVIDIMOS ENTRE 2, EL RESTO SE GUARDARA EN AH Y EL COCIENTE EN AL
			DIV divisor
			; GUARDAMOS DX EN NUESTRO VECTOR RESULTADO
			MOV resultado[SI], AH
			; INCREMENTAMOS SI PARA MULTIPLICAR LA SIGUIENTE COLUMNA
			INC SI
			; COMPARAMOS SI CON 7 PARA SABER SI HEMOS TERMINADO DE REALIZAR LA MULTIPLICACION
			CMP SI, 7
			; SI SI ES IGUAL A 7 SIGNIFICARA QUE HEMOS TERMINADO DE HACER LA MULTIPLICACION
			JNE bucle8
		; VOLVEMOS A LA ZONA DE LA RUTINA EN LA QUE HEMOS LLAMADO A LA FUNCION
		RET 
	multiplicacion ENDP
	
	multiplicacion_columna PROC
			; INICIALIZAMOS AX A 0 PARA REALIZAR CORRECTAMENTE LA MULTIPLICACION
			MOV AX, 0
			; GUARDAMOS EN AL EL VALOR DE LA MATRIZ QUE VAMOS A MULTIPLICAR
			MOV AL, generacion[SI][BX]
			; GUARDAMOS EN BX EL VALOR DEL VECTOR QUE VAMOS A MULTIPLICAR
			MOV CL, vector[DI]
			; MULTIPLICAMOS EL VALOR DE LA MATRIZ POR EL DEL VECTOR
			MUL CL
			; GUARDAMOS LA SUMA DE LAS MULTIPLICACIONES EN DX
			ADD DX, AX
			; AUMENTAMOS EL INDICE DEL VECTOR PARA MOVERNOS UNA POSICION
			INC DI
			; AUMENTAMOS CX PARA MOVERNOS UNA PASAR A LA SIGUIENTE FILA(SUMAMOS 7)
			ADD BX, 7
			; COMPROBAMOS SI DI ES IGUAL A 4 PARA SABER SI YA HEMOS MULTIPLICADO LAS FILAS
			CMP DI, 4
			; SI DI ES IGUAL A 4 SIGNIFICA QUE HEMOS LLEGADO AL FINAL DEL VECTOR POR LO QUE SE ACABA LA MULTIPLICACION DE LA FILA
			JNE multiplicacion_columna
			; VOLVEMOS AL LUGAR EN EL QUE HAN LLAMADO A LA FUNCION MULTIPLICACION
			RET
	multiplicacion_columna ENDP

	; LA FUNCION COLOCACION_BITS_PARIDAD COLOCA CORRECTAMENTE LOS BITS DEL VECTOR P1 P2 D1 P3 D2 D3 D4
	colocacion_bits_paridad PROC
			; GUARDAMOS EL BYTE QUE VAMOS A COLOCAR
			MOV AL, resultado[0]
			; GUARDAMOS EL BYTE QUE VAMOS A REEMPLAZAR
			MOV BL, resultado[2]
			; COLOCAMOS EL PRIMER BYTE
			MOV resultado[2], AL
			; GUARDAMOS EL VALOR DONDE VAMOS A COLOCAR EL BYTE 2 DEL RESULTADO
			MOV AL, resultado[5]
			; COLOCAMOS EL BYTE 2 DEL RESULTADO QUE SE HA QUEDADO SIN POSICION
			MOV resultado[5], BL
			; GUARDAMOS EL VALOR DONDE VAMOS A COLOCAR EL BYTE 5 DEL RESULTADO
			MOV BL, resultado[1]
			; COLOCAMOS EL BYTE 5 DEL RESULTADO QUE SE HA QUEDADO SIN POSICION
			MOV resultado[1], AL
			; GUARDAMOS EL VALOR DONDE VAMOS A COLOCAR EL BYTE 1 DEL RESULTADO
			MOV AL, resultado[4]
			; COLOCAMOS EL BYTE 1 DEL RESULTADO QUE SE HA QUEDADO SIN POSICION
			MOV resultado[4], BL
			; COLOCAMOS EL BYTE 4 DEL RESULTADO QUE SE HA QUEDADO SIN POSICION
			MOV resultado[0], AL
			; GUARDAMOS EL 3 BYTE DE RESULTADO PARA COLOCARLO
			MOV AL, resultado[3]
			; GUARDAMOS EL VALOR CONTENIDO EN EL 6 BYTE DE RESULTADO
			MOV BL, resultado[6]
			; COLOCAMOS EL 3 BYTE CORRECTAMENTE
			MOV resultado[6], AL
			; COLOCAMOS CORRECTAMENTE EL BYTE QUE HABIAMOS GUARDADO PREVIAMENTE
			MOV resultado[3], BL
			; VOLVEMOS A LA ZONA DE RUTINA EN LA QUE HEMOS LLAMADO A LA FUNCION
			RET
	colocacion_bits_paridad ENDP
	
	; FUNCION DE IMPRESION DE LA CABECERA
	imprimir_cabecera PROC
		MOV DX, OFFSET cabecera
		MOV AH, 9
		INT 21H
		CALL imprimir_salto_linea
		RET
	imprimir_cabecera ENDP
	
	; FUNCION DE IMPRESION DE LA CADENA "INPUT: "
	imprimir_input PROC
		MOV DX, OFFSET input
		MOV AH, 9
		INT 21H
		RET
	imprimir_input ENDP
	
	; FUNCION DE IMPRESION DE LA CADENA "OUTPUT: "
	imprimir_output PROC
		MOV DX, OFFSET output
		MOV AH, 9
		INT 21H
		RET
	imprimir_output ENDP
	
	; FUNCION DE IMPRESION DE UN SALTO DE LINEA
	imprimir_salto_linea PROC
		MOV DX, OFFSET intro
		MOV AH, 9
		INT 21H
		RET
	imprimir_salto_linea ENDP
	
	; FUNCION PARA IMPRIMIR EL CARACTER BARRA
	imprimir_barra PROC
		MOV DX, OFFSET barra
		MOV AH, 9
		INT 21H
		RET
	imprimir_barra ENDP
	
	; FUNCION PARA IMPRIMIR EL INPUT, ES DECIR EL VECTOR 1X4
	imprimir_vector PROC
		CALL imprimir_input
		MOV DI, 0
		CALL imprimir_barra
		bucle1:
			MOV BX, 0
			MOV BL, vector[DI]
			ADD BX, 30h
			MOV DL, BL
			MOV AH, 2
			INT 21H
			CALL imprimir_barra
			INC DI
			CMP DI,4
			JNE bucle1
		RET
	imprimir_vector ENDP
	
	; FUNCION PARA IMPRIMIR EL OUTPUT, ES DECIR EL VECTOR RESULTADO
	imprimir_resultado PROC
		CALL imprimir_output
		MOV DI, 0
		CALL imprimir_barra
		bucle2:
			MOV BX, 0
			MOV BL, resultado[DI]
			ADD BX, 30h
			MOV DL, BL
			MOV AH, 2
			INT 21H
			MOV DX, OFFSET barra
			MOV AH, 9
			INT 21H
			INC DI
			CMP DI, 7
			JNE bucle2
		RET
	imprimir_resultado ENDP
	
	; FUNCION PARA IMPRIMIR LA CADENA DE CARACTERES COMPUTATION
	imprimir_computation PROC
		MOV DX, OFFSET computation
		MOV AH, 9
		INT 21H
		CALL imprimir_salto_linea
		RET
	imprimir_computation ENDP
	
	; FUNCION PARA IMPRIMIR LA TABLA RESULTANTE
	imprimir_tabla PROC
		CALL imprimir_computation
		CALL imprimir_cabecera
		CALL imprimir_word
		CALL imprimir_p1
		CALL imprimir_p2
		CALL imprimir_p3
		RET
	imprimir_tabla ENDP
	
	; FUNCION PARA IMPRIMIR LA CADENA WORDS
	imprimir_word PROC
		CALL imprimir_tab
		MOV DX, OFFSET words
		MOV BX,0
		MOV AH, 9
		INT 21H
		CALL imprimir_barra
		CALL imprimir_interrogacion
		CALL imprimir_barra
		CALL imprimir_interrogacion
		CALL imprimir_barra
		MOV BL, resultado[2]
		ADD BX, 30h
		MOV DL, BL
		MOV AH, 2
		INT 21H
		CALL imprimir_barra
		CALL imprimir_interrogacion
		CALL imprimir_barra
		MOV DI, 4
		bucle3:
			MOV BL, resultado[DI]
			ADD BX, 30h
			MOV DL, BL
			MOV AH, 2
			INT 21H
			CALL imprimir_barra
			INC DI
			CMP DI,7
			JNE bucle3
		CALL imprimir_salto_linea
		RET
	imprimir_word ENDP
		
	; FUNCION PARA IMPRIMIR LA CADENA P1
	imprimir_p1 PROC
		CALL imprimir_tab
		MOV DX, OFFSET p1
		MOV AH, 9
		INT 21H
		CALL imprimir_barra
		MOV BL, resultado[0]
		ADD BX, 30h
		MOV DL, BL
		MOV AH, 2
		INT 21H
		CALL imprimir_barra
		CALL imprimir_espacio
		CALL imprimir_barra
		MOV BL, resultado[2]
		ADD BX, 30h
		MOV DL, BL
		MOV AH, 2
		INT 21H
		CALL imprimir_barra
		CALL imprimir_espacio
		CALL imprimir_barra
		MOV BL, resultado[4]
		ADD BX, 30h
		MOV DL, BL
		MOV AH, 2
		INT 21H
		CALL imprimir_barra
		CALL imprimir_espacio
		CALL imprimir_barra
		MOV BL, resultado[6]
		ADD BX, 30h
		MOV DL, BL
		MOV AH, 2
		INT 21H
		CALL imprimir_barra
		CALL imprimir_salto_linea
		RET
	imprimir_p1 ENDP
	
	; FUNCION PARA IMPRIMIR LA CADENA P2
	imprimir_p2 PROC
		CALL imprimir_tab
		MOV DX, OFFSET p2
		MOV AH, 9
		INT 21H
		CALL imprimir_barra
		CALL imprimir_espacio
		CALL imprimir_barra
		MOV BL, resultado[1]
		ADD BX, 30h
		MOV DL, BL
		MOV AH, 2
		INT 21H
		CALL imprimir_barra
		MOV BL, resultado[2]
		ADD BX, 30h
		MOV DL, BL
		MOV AH, 2
		INT 21H
		CALL imprimir_barra
		CALL imprimir_espacio
		CALL imprimir_barra
		CALL imprimir_espacio
		CALL imprimir_barra
		MOV DI, 5
		bucle4:
			MOV BL, resultado[DI]
			ADD BX, 30h
			MOV DL, BL
			MOV AH, 2
			INT 21H
			INC DI
			CALL imprimir_barra
			CMP DI, 7
			JNE bucle4
		CALL imprimir_salto_linea
		RET
	imprimir_p2 ENDP
	
	; FUNCION PARA IMPRIMIR LA CADENA P3
	imprimir_p3 PROC
		CALL imprimir_tab
		MOV DX, OFFSET p3
		MOV AH, 9
		INT 21H
		CALL imprimir_barra
		CALL imprimir_espacio
		CALL imprimir_barra
		CALL imprimir_espacio
		CALL imprimir_barra
		CALL imprimir_espacio
		CALL imprimir_barra
		MOV DI, 3
		bucle5:
			MOV BL, resultado[DI]
			ADD BX, 30h
			MOV DL, BL
			MOV AH, 2
			INT 21H
			INC DI
			CALL imprimir_barra
			CMP DI, 7
			JNE bucle5
		CALL imprimir_salto_linea
		RET
	imprimir_p3 ENDP
	
	; FUNCION PARA IMPRIMIR EL CARACTER INTERROGACION
	imprimir_interrogacion PROC
		MOV AH, 2
		MOV DL, '?'
		INT 21H
		RET
	imprimir_interrogacion ENDP
	
	; FUNCION PARA IMPRIMIR EL CARACTER ESPACION
	imprimir_espacio PROC
		MOV AH, 2
		MOV DL, ESPACIO
		INT 21H
		RET
	imprimir_espacio ENDP
	
	; FUNCION PARA IMPRIMIR UNA TABULACION
	imprimir_tab PROC
		MOV DX, OFFSET tabulador
		MOV AH, 9
		INT 21H
		RET
	imprimir_tab ENDP
	
	; FUNCION QUE LEE Y GUARDA UNA CADENA DE CARACTERES INTRODUCIDA POR TECLADO
	lectura_teclado PROC
		MOV AH,0AH ;Función captura de teclado
		MOV DX,OFFSET vector ;Área de memoria reservada = etiqueta vector
		MOV vector[0], 10 ;Lectura de caracteres máxima=4
		INT 21H
		RET
	lectura_teclado ENDP
	
	; FUNCION PARA IMPRIMIR MENSAJE  DE ERROR
	imprimir_error PROC
		MOV DX, OFFSET cadena_error
		MOV AH, 9
		INT 21H
		RET
	imprimir_error ENDP
	
	; FUNCION PARA IMPRIMIR MENSAJE DE SALIDA
	imprimir_salida PROC
		MOV DX, OFFSET cadena_salir
		MOV AH, 9
		INT 21H
		RET
	imprimir_salida ENDP
	
	; FUNCION DE COMPROBACION SI EL NUMERO SE ENCUENTRA ENTRE 0 Y 15
	comprobacion_lectura PROC
		; PONEMOS EL INDICE A 2 PARA RECORRER LA CADENA
		MOV DI, 2
		; GUARDAMOS EN AX EL NUMERO DE CARACTERES QUE SE HAN ESCRITO EN VECTOR
		MOV AL, vector[1]
		; SI SON 2 CARACTERES VAMOS A LA RUTINA DOS CARACTERES Y SI SON MENOS VAMOS A LA RUTINA UN CARACTER
		CMP AL, 2
		; SI SON 2 CARACTERES SALTA A LA RUTINA DOS CARACTERES
		JE dos_caracteres
		; COMPRUEBA SI SE HA ESCRITO UN CARACTER
		CMP AL, 1
		; SI ES UN CARACTER SALTA A LA RUTINA un_caracter
		JE un_caracter
		; COMPRUEBA SI LA CADENA SON 5 CARACTERES
		CMP AL, 5
		; SI SON 5 CARACTERES SALTA A LA RUTINA SALIR
		JE salir
		; SI NO ES NINGUNO DE LOS CASOS ANTERIORES IMPRIME MENSAJE DE ERROR Y ACABA EL PROGRAMA
		CALL imprimir_error
		JMP fin
		dos_caracteres:
			CALL cambio_dos_caracteres
			RET
		un_caracter:
			CALL cambio_un_caracter
			RET
		salir:
			CALL comprobacion_salir
	comprobacion_lectura ENDP

	; FUNCION PARA TRANSFORMAR DE ASCII A DECIMAL UN NUMERO DE DOS CARACTERES
	cambio_dos_caracteres PROC
		; GUARDAMOS EL PRIMER CARACTER EN BL
		MOV BL, vector[2]
		; COMPROBAMOS SI EL PRIMER CARACTER ES IGUAL A 31, YA QUE SI NO LO ES SIGNIFICARA QUE EL NUMERO ES MAYOR QUE 15
		CMP BL, 31h
		; SI EL NUMERO ES DIFERENTE A 31 SALTAMOS A LA RUTINA ERROR
		JNE rutina_error
		; SI EL NUMERO ES IGUAL A 31 CONTINUAMOS CON LA COMPROBACION DEL SEGUNDO DIGITO
		; PRIMERO GUARDAMOS EN BL EL SEGUNDO DIGITO
		MOV BL, vector[3]
		; COMPROBAMOS SI EL NUMERO ES MAYOR QUE 35, ES DECIR, MAYOR QUE 5
		CMP BL, 35h
		; SI EL NUMERO ES MAYOR QUE 35 SALTAMOS A LA RUTINA ERROR
		JA rutina_error
		; SI EL NUMERO ES MENOR QUE 35 PASAMOS A TRANSFORMARLO A DECIMAL
		; GUARDAMOS EN DL EL NUMERO 30 PARA RESTARSELO AL CODIGO ASCII QUE HEMOS LEIDO
		MOV DL, 30h
		; PRIMERO RESTAMOS EL NUMERO MENOS 30 PARA PASARLO A DECIMAL Y LO GUARDAMOS EN BL
		SUB BL, DL
		; A CONTINUACION LE SUMAMOS 10, YA QUE ES UN NUMERO DE DOS CARACTERES
		ADD BL, 10
		; VOLVEMOS AL LUGAR DONDE HAN LLAMADO A LA FUNCION
		RET
		rutina_error:
			CALL imprimir_error
			JMP fin
	cambio_dos_caracteres ENDP
	
	; FUNCION PARA TRANSFORMAR DE ASCII A DECIMAL UN NUMERO DE UN CARACTER
	cambio_un_caracter PROC
		; GUARDAMOS EL PRIMER CARACTER EN BL
		MOV BL, vector[2]
		; COMPROBAMOS SI EL CARACTER ES MAYOR QUE 0
		CMP BL, 30h
		; SI ES MENOR QUE 0 SALTAMOS A LA RUTINA ERROR
		JB rutina_error2
		; COMPROBAMOS SI EL CARACTER ES MAYOR QUE 9
		CMP BL, 39h
		; SI ES MAYOR QUE 9 SALTAMOS A LA RUTINA ERROR
		JA rutina_error2
		; SI EL NUMERO ESTA ENTRE 0 Y 9 PASAMOS EL CODIGO DE ASCII A DECIMAL
		; GUARDAMOS EN DL EL NUMERO 30 PARA RESTARSELO AL CODIGO ASCII QUE HEMOS LEIDO
		MOV DL, 30h
		; PRIMERO RESTAMOS EL NUMERO MENOS 30 PARA PASARLO A DECIMAL Y LO GUARDAMOS EN DL
		SUB BL, DL
		; VOLVEMOS AL LUGAR DONDE HEMOS LLAMADO A LA FUNCION
		RET
		rutina_error2:
			CALL imprimir_error
			JMP fin
	cambio_un_caracter ENDP
	
	; FUNCION PARA COMPROBAR SI SE HA ESCRITO LA CADENA SALIR
	comprobacion_salir PROC
		; GUARDAMOS EN BL EL PRIMER CARACTER DE LA CADENA
		MOV BL, vector[2]
		; COMPROBAMOS SI EL PRIMER CARACTER ES s
		CMP BL, 's'
		; SI NO LO ES SALTAMOS A LA RUTINA DE ERROR
		JNE rutina_error3
		; GUARDAMOS EN BL EL SEGUNDO CARACTER DE LA CADENA
		MOV BL, vector[3]
		; COMPROBAMOS SI EL SEGUNDO CARACTER ES a
		CMP BL, 'a'
		; SI NO LO ES SALTAMOS A LA RUTINA DE ERROR
		JNE rutina_error3
		; GUARDAMOS EN BL EL TERCER CARACTER DE LA CADENA
		MOV BL, vector[4]
		; COMPROBAMOS SI EL SEGUNDO CARACTER ES l
		CMP BL, 'l'
		; SI NO LO ES SALTAMOS A LA RUTINA DE ERROR
		JNE rutina_error3
		; GUARDAMOS EN BL EL CUARTO CARACTER DE LA CADENA
		MOV BL, vector[5]
		; COMPROBAMOS SI EL SEGUNDO CARACTER ES a
		CMP BL, 'i'
		; SI NO LO ES SALTAMOS A LA RUTINA DE ERROR
		JNE rutina_error3
		; GUARDAMOS EN BL EL QUINTO CARACTER DE LA CADENA
		MOV BL, vector[6]
		; COMPROBAMOS SI EL SEGUNDO CARACTER ES a
		CMP BL, 'r'
		; SI NO LO ES SALTAMOS A LA RUTINA DE ERROR
		JNE rutina_error3
		; SI TODO HA FUNCIONANDO IMPRIMIMOS LA CADENA DE SALIDA 
		CALL imprimir_salida
		; SALTAMOS AL FINAL DEL PROGRAMA
		JMP fin
		rutina_error3:
			CALL imprimir_error
			JMP fin
	comprobacion_salir ENDP
	
	; FUNCION PARA TRANSFORMAR UN NUMERO A BINARIO Y GUARDARLO EN LA VARIABLE VECTOR
	transformacion_binario PROC
		; INICIALIZAMOS LA VARIABLE VECTOR A 0
		CALL reseteo_vector
		; INICIALIZAMOS EL CONTADOR DEL VECTOR A 3
		MOV DI, 3
		; GUARDAMOS EN BH 0 COMO CONTROL DE ERRORES, PARA NO TENER PROBLEMAS A LA HORA DE DIVIDIR
		MOV BH, 0
		bucle6:
			; GUARDAMOS EN DX 0000h PARA PODER ESCRIBIR CORRECTAMENTE EL DIVIDENDO DE 32 bits
			MOV DX, 0000h
			; GUARDAMOS EN AX EL NUMERO QUE VAMOS A DIVIDIR
			MOV AX, BX
			; GUARDAMOS EN CX EL DIVISOR, QUE EN ESTE CASO SERA 10, PARA PODER IR OBTENIENDO TODAS LAS CIFRAS DEL NUMERO
			MOV CX, 0002h
			; DIVIDIMOS NUESTRO NUMERO ENTRE 10
			DIV CX
			; EL COCIENTE DE LA DIVISION LO GUARDAMOS EN BX PARA SEGUIR DIVIDIENDOLO EN BUCLE
			MOV BX, AX
			; EL RESTO LO GUARDAMOS EN AX(SERAN LAS CIFRAS DE NUESTRO NUMERO DESDE EL FINAL, UNA EN CADA BUCLE)
			MOV AX, DX
			; GUARDAMOS DE ATRAS HACIA ADELANTE EN EL VECTOR
			MOV VECTOR[DI],AL
			; AUEMENTAMOS SI PARA FACILITAR EL VACIADO DE LA PILA
			DEC DI
			; COMO CONTROL DE ERRORES ANIADIDO COMPROBAMOS SI EL INDICE ES NEGATIVO
			CMP DI, 0
			; SI EL INDICE ES MENOR QUE 0 SALTAMOS A LA RUTINA DE ERROR
			JB rutina_error4
			; COMPARAMOS SI EL COCIENTE ES IGUAL A 0h
			CMP BX, 0h
			; SI EL COCIENTE NO ES 0 SE SIGUE DIVIDENDO
			JNE bucle6
		; VOLVEMOS A LA ZONA DONDE SE HA LLAMADO LA FUNCION
		RET
		rutina_error4:
			CALL imprimir_error
			JMP fin
	transformacion_binario ENDP
	
	reseteo_vector PROC
		; PONEMOS EL INDICE A 0 PARA RECORRER EL ARRAY VECTOR
		MOV SI, 0
		bucle7:
			; PONEMOS LA POSICION DEL VECTOR A 0
			MOV vector[SI], 0
			; INCREMENTAMOS EL INDICE PARA RECORRER EL VECTOR
			INC SI
			; COMPROBAMOS SI EL INDICE ES IGUAL A 4
			CMP SI, 4
			; SI EL INDICE ES IGUAL A 4 SALIMOS DE LA FUNCION YA QUE HA FINALIZADO EL RESETEO
			JNE bucle7
		RET
	reseteo_vector ENDP
;**************************************************************************************	

; FIN DEL PROGRAMA
fin:
	MOV AX, 4C00H
	INT 21H
	INICIO ENDP
; FIN DEL SEGMENTO DE CODIGO
CODE ENDS
; FIN DEL PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION
END INICIO