;********************************************************************************
; PRACTICA 4, EJERCICIO A -> TOMAS HIGUERA VISO Y GUILLERMO HOYO BRAVO, PAREJA 1*
;********************************************************************************
; DEFINICION DEL SEGMENTO DE CODIGO                                             *
;********************************************************************************

codigo SEGMENT 
	ASSUME cs : codigo
	ORG 256
	
inicio:
	; PRIMERO COMPROBAMOS CUAL ES EL VALOR QUE SE HA INTRODUCIDO COMO ARGUMENTO
	; VAMOS A LA POSICION 80h DE PSP QUE CONTIENE EL NUMERO DE ARGUMENTOS DE ENTRADA
	MOV AL, CS:[80h]
	; COMPROBAMOS SI EL NUMERO DE ARGUMENTOS DE ENTRADA ES 0
	CMP AL, 0
	; SI ES 0 SALTAMOS A LA RUTINA  DE NO_ARGUMENTOS
	JE no_argumentos
	; SI NO ES 0 SALTAMOS A LA RUTINA DE ARGUMENTOS
	JMP argumentos
	argumentos:
		; LLAMAMOS A LA RUTINA DE NO ARGUMENTOS
		CALL argumentos_proc
		; FINALIZAMOS EL PROGRAMA
		MOV AX, 4C00H
		INT 21H
	no_argumentos:
		; LLAMAMOS A LA RUTINA DE INICIO DE PROGRAMA CON ARGUMENTOS
		CALL no_argumentos_proc
		; FINALIZAMOS EL PROGRAMA
		MOV AX, 4C00H
		INT 21H

;*******************************************
;*******VARIABLES DE NUESTRO PROGRAMA*******	
;*******************************************

; VARIABLE PARA IMPRIMIR QUE EL DRIVER SE HA INSTALADO CORRECTAMENTE
instalado_correcto DB "EL DRIVER SE HA INSTALADO CORRECTAMENTE",'$'
; VARIABLE PARA IMPRIMIR QUE EL DRIVER SE HA DESINSTALADO CORRECTAMENTE
desintalado_correcto DB "DRIVER DESINSTALADO CORRECTAMENTE",'$'
; VARIABLE PARA IMPRIMIR QUE EL DRIVER YA SE ENCONTRABA INSTALADO
instalado_previamente DB "EL DRIVER YA SE ENCUENTRA INSTALADO",'$'
; VARIABLE PARA IMPRIMIR QUE EL DRIVER NO SE ENCUENTRA INSTALADO
no_instalado_previamente DB "EL DRIVER NO SE ENCUENTRA INSTALADO",'$'
; VARIABLE QUE UTILIZAREMOS PARA IMPRIMIR QUE LOS ARGUMENTOS NO SON VALIDOS
no_validos DB "ARGUMENTOS DEL PROGRAMA NO VALIDOS",'$'
; VARIABLE QUE UTILIZAREMOS PARA IMPRIMIR QUE NUESTRO DRIVER SE ENCUENTRA INSTALADO
string_instalado DB "DRIVER INSTALADO",'$'
; VARIABLE CON LA QUE IMPRIMIREMOS EL SALTO DE LINEA
intro db 13,10,'$'
; VARIABLE QUE UTILIZAREMOS PARA IMPRIMIR QUE NUESTRO DRIVER NO SE ENCUENTRA INSTALADO
string_no_instalado DB "DRIVER NO INSTALADO",'$'
; VARIABLE QUE GUARDA INFORMACION SOBRE NUESTRO GRUPO Y NOMBRES
string_info DB "2272, GUILLERMO HOYO Y TOMAS HIGUERA, PARA INSTALAR EJECUTA CON EL ARGUMENTO /I Y PARA DESINSTALAR CON EL ARGUMENTO /D. NUESTRO NUMERO SECRETO ES 4.",'$'
; VARIABLE EN LA QUE GUARDAREMOS EL SEGMENTO Y EL OFFSET DE LA INTERRUPCION 60h ANTES DE MODIFICARLA
old_60h DW 0,0
; VARIABLE PARA GUARDAR LA CADENA CODIFICADA O SIN DECODIFICAR
cadena_guardada DB 50 DUP (0)
; VARIABLE FLAG QUE UTILIZAREMOS PARA COMPROBAR SI NUESTRO DRIVER SE HA INSTALADO CORRECTAMENTE
flag DW 0CAFEh

; RUTINA DE SERVICIO A LA INTERRUPCION
rsi PROC FAR
	; GUARDAMOS EN PILA LOS REGISTROS QUE VAMOS A USAR
	PUSH DI SI AX BX CX DX DS
	; COMPROBAMOS SI LA INTERRUPCION SE HA LLAMADO PARA CODIFICAR O DECODIFICAR
	CMP AH, 1
	; SI AH ES 1 SE LLAMA A LA CODIFICACION
	JE codificar
	; SI AH ES DISTINTO COMPROBAMOS SI ES 2
	CMP AH, 2
	; SI AH ES 2 SALTAMOS A LA DECODIFACION
	JE decodificar
	; SI AH NO CODIFICA NI DECODIFICA SALIMOS DEL PROGRAMA
	JMP fin_rutina
	codificar:
		; LLAMAMOS AL PROCEDIMIENTO DE CODIFICACION
		CALL codificacion
		; SALTAMOS A LA RUTINA DE FIN DE PROGRAMA
		JMP fin_rutina
	decodificar:
		; LLAMAMOS AL PROCEDIMIENTO DE DECODIFACION
		CALL decodificacion
		; SALTAMOS A LA RUTINA DE FIN DE PROGRAMA
		JMP fin_rutina
	fin_rutina:
		; IMPRIMIMOS LA CADENA GUARDADA
		CALL imprimir_guardada
		; RECUPERAMOS LOS RESGISTROS UTILIZADOS
		POP DS DX CX BX AX SI DI
		; VOLVEMOS DONDE SE HA LLAMADO LA RUTINA
		IRET
rsi ENDP

codificacion PROC
	; PONEMOS EL INDICE PARA RECORRER EL ARRAY DE CARACTERES A 0
	MOV DI, 0
	bucle_codificacion:
		; GUARDAMOS EN BX EL OFFSET QUE SE ENCUENTRA EN DX
		MOV BX, DX
		; GUARDAMOS EL PRIMER CARACTER EN CL
		MOV CL, DS:[BX + DI]
		; COMPROBAMOS SI ES EL CARACTER FIN DE CADENA
		CMP CL, 24h
		; SI ES EL CARACTER FIN DE CADENA SALTAMOS A LA RUTINA DE FIN
		JE fin_codificacion
		; COMPROBAMOS SI EL CARACTER ES EL ESPACIO
		CMP CL, 20h
		; SI EL CARACTER ES EL ESPACIO SALTAMOS A LA RUTINA DE CARACTER ESPACIO
		JE caracter_espacio
		; SUMAMOS 4 A CL
		ADD CL, 4
		; GUARDAMOS EN NUESTRA CADENA EL CARACTER MAS 4
		MOV cadena_guardada[DI], CL
		; INCREMENTAMOS EN UNO DI
		INC DI
		; VOLVEMOS AL COMIENZO DEL BUCLE
		JMP bucle_codificacion
		fin_codificacion:
			; GUARDAMOS EN LA CADENA DE GUARDADO EL CARACTER DE FIN DE CADENA
			MOV cadena_guardada[DI], 24h
			; VOLVEMOS DONDE SE HA LLAMADO LA RUTINA
			RET
		caracter_espacio:
			; GUARDAMOS EN LA CADENA EL CARACTER ESPACIO
			MOV cadena_guardada[DI], 20h
			; INCREMENTAMOS EL INDICE
			INC DI
			; VOLVEMOS AL BUCLE DE CODIFICACION
			JMP bucle_codificacion
codificacion ENDP

decodificacion PROC
	; PONEMOS EL INDICE PARA RECORRER EL ARRAY DE CARACTERES A 0
	MOV DI, 0
	bucle_decodificacion:
		; GUARDAMOS EN BX EL OFFSET QUE SE ENCUENTRA EN DX
		MOV BX, DX
		; GUARDAMOS EL PRIMER CARACTER EN CL
		MOV CL, DS:[BX][DI]
		; COMPROBAMOS SI ES EL CARACTER FIN DE CADENA
		CMP CL, 24h
		; SI ES EL CARACTER FIN DE CADENA SALTAMOS A LA RUTINA DE FIN
		JE fin_decodificacion
		; COMPROBAMOS SI EL CARACTER ES EL ESPACIO
		CMP CL, 20h
		; SI EL CARACTER ES EL ESPACIO SALTAMOS A LA RUTINA DE CARACTER ESPACIO
		JE caracter_espacio2
		; DECREMETAMOS CL 4
		SUB CL, 4
		; GUARDAMOS EN NUESTRA CADENA EL CARACTER MAS 4
		MOV cadena_guardada[DI], CL
		; INCREMENTAMOS EN UNO DI
		INC DI
		; VOLVEMOS AL COMIENZO DEL BUCLE
		JMP bucle_decodificacion
		fin_decodificacion:
			; GUARDAMOS EN LA CADENA DE GUARDADO EL CARACTER DE FIN DE CADENA
			MOV cadena_guardada[DI], 24h
			; VOLVEMOS DONDE SE HA LLAMADO LA RUTINA
			RET
		caracter_espacio2:
			; GUARDAMOS EN LA CADENA EL CARACTER ESPACIO
			MOV cadena_guardada[DI], 20h
			; INCREMENTAMOS EL INDICE
			INC DI
			; VOLVEMOS AL BUCLE DE CODIFICACION
			JMP bucle_decodificacion
decodificacion ENDP

imprimir_guardada PROC
	; GUARDAMOS EL CS EN BX PARA PODER ASIGNARLO A CONTINUACION A DS
	MOV BX, CS
	; COLOCAMOS DS EN CS PARA IMPRIMIR CORRECTAMENTE
	MOV DS, BX
	; GUARDAMOS EN DX EL OFFSET DEL STRING QUE VAMOS A IMPRIMIR
	MOV DX, OFFSET cadena_guardada
	; GUARDAMOS EN AH 9 PARA IMPRIMIR CON LA INTERRUPCION 21h
	MOV AH, 9
	; IMPRIMIMOS LLAMANDO A LA INTERRUPCION 21h
	INT 21h
	; VOLVEMOS DONDE SE HA LLAMADO LA RUTINA
	RET
imprimir_guardada ENDP

	; PROCEDIMIENTO QUE INSTALA NUESTRO DRIVER
	instalador PROC
		; COMPROBAMOS SI NUESTRO DIVER ESTA INSTALADO
		CALL comprobacion_driver
		; COMPROBAMOS EL VALOR DE AX
		CMP AX, 1
		; SI AX ES 1 NUESTRO DRIVER YA SE ENCUENTRA INSTALADO ASI QUE FINALIZAMOS EL PROGRAMA
		JE fin
		; GUARDAMOS 0 EN AX PARA MOVERNOS POR EL SEGMENTO DE INTERRUPCION
		XOR AX, AX
		; COLOCAMOS ES EN EL SEGMENTO 0
		MOV ES, AX
		; DESACTIVAMOS LAS INTERRUPCIONES
		CLI
		; GUARDAMOS EN AX EL OFFSET ASIGNADO A LA INTERRUPCION 60h
		MOV AX, ES:[60h*4]
		; GUARDAMOS EL OFFSET ANTERIOR EN OLD_60H
		MOV old_60h, AX
		; GUARDAMOS EN AX EL SEGMENTO ASIGNADO A LA INTERRUPCION 60H
		MOV AX, ES:[60h*4+2]
		; GUARDAMOS EL SEGMENTO ANTERIOR EN OLD_60H
		MOV old_60h + 2, AX
		; ASIGNAMOS EL OFFSET Y EL SEGMENTO A NUESTRO VECTOR DE INTERRUPCION
		; ASIGNACION DEL OFFSET EN EL VECTOR INTERRUPCION
		MOV ES:[60h*4], OFFSET rsi
		; ASIGNACION DEL SEGMENTO EN EL VECTOR INTERRUPCION
		MOV ES:[60h*4+2], CS
		; ACTIVAMOS DE NUEVO LAS INTERRUPCIONES
		STI
		; LLAMAMOS A LA RUTINA PARA IMPRIMIR QUE NUESTRO DRIVER ESTA INSTALADO
		CALL imprimir_instalado_correcto
		; ESTABLECEMOS EL LIMITE DE INSTALACION
		MOV DX, OFFSET instalador
		; EJECUTAMOS LA INTERRUPCION 27h PARA DEJAR EL PROGRAMA RESIDENTE
		INT 27h
		; VOLVEMOS DONDE SE HA LLAMADO LA RUTINA
		RET
		fin:
			; IMPRIMIMOS QUE ESTA INSTALADO Y VOLVEMOS DONDE SE HA LLAMADO LA RUTINA
			CALL imprimir_instalado_previo
			RET
	instalador ENDP

	; PROCEDIMIENTO QUE DESINSTALA NUESTRO DRIVER
	desinstalar_60h PROC
		; COMPROBAMOS SI EL DRIVER ESTA INSTALADO
		CALL comprobacion_driver
		; COMPARAMOS EL VALOR DE AX A 0, SI ES IGUAL A 0 NO ESTA INSTALADO
		CMP AX, 0
		;SI ES IGUAL A 0 SALTAMOS A FIN YA QUE NO PODEMOS DESINSTALAR EL PROGRAMA
		JE fin2
		; PONERMOS CX A 0
		MOV CX, 0
		; PONEMOS EL DATA SEGMENT AL VECTOR DE INTERRUPCIONES
		MOV DS, CX
		; INHABILITAMOS LAS INTERRUPCIONES
		CLI
		; MOVEMOS EL EXTRA SEGMENT AL SEGMENTO DE LA INTERRUPCION INSTALADA
		MOV ES, DS:[60h*4+2]
		; MOVEMOS CX AL SEGMENTO DE LAS VARIABLES DE ENTORNO
		MOV CX, ES:[2Ch]
		; MOVEMOS A AH 49h PARA REALIZAR LA DESINSTALACION DE LAS VARIABLES DE ENTORNO GUARDADS EN EL PSP
		MOV AX, 4900h
		; EJECUTAMOS LA INTERRUPCION 21h PARA LIBERAR EL SEGMENTO DE RSI
		INT 21h
		; MOVEMOS EL EXTRASEGMENT A CX PARA GUARDAR EN EL EL SEGMENTO DE LAS VARIABLES DE ENTORNO Y PODER LIBERARLO
		MOV ES, CX
		; LIBERAMOS EL SEGMENTO DE LAS VARIABLES DE ENTORNO LLAMANDO A LA INTERRUPCION 21H
		INT 21h
		; PONEMOS AX A 0
		XOR AX, AX
		; COLOCAMOS EL ES EN 0
		MOV ES, AX
		; PONERMOS EL VALOR DEL SEGMENTO INTERRUPCION 60H AL DEL SEGMENTO DE LA INTERRUPCION GUARDADA ANTERIORMENTE EN OLD_60H +2
		MOV AX, old_60h+2
		; GUARDAMOS AX EN LA INTERRUPCION
		MOV ES:[60h*4+2], AX
		; MOVEMOS EL OFFSET DEL SEGMENTO INTERRUPCION 60H AL DEL SEGMENTO DE LA INTERRUPCION GUARDADA ANTERIORMENTE EN OLD_60H
		MOV AX, old_60h
		; GUARDAMOS AX EN LA INTERRUPCION
		MOV ES:[60h*4], AX
		; HABILITAMOS LAS INTERRUPCIONES
		STI
		; IMPRIMIMOS QUE EL DRIVER SE ENCUENTRA DESINSTALADO
		CALL imprimir_desinstalado_correcto
		; VOLVEMOS DONDE SE HA LLAMADO LA RUTINA
		RET
		fin2:
			; IMPRIMIMOS QUE ESTA DESINSTALADO
			CALL imprimir_no_instalado_previo
			; VOLVEMOS DONDE SE HA LLAMADO LA RUTINA
			RET
	desinstalar_60h ENDP
		
	no_argumentos_proc PROC
		; IMPRIMIMOS LA DESCRIPCION QUE HEMOS DEFINIDO EN STRING_INFO
		CALL info
		; GUARDAMOS EN CX 0 PARA PODER BUSCAR EN EL SEGMENTO DE VECTORES DE INTERRUPCION
		MOV CX, 0
		; MOVEMOS ES AL SEGMENTO DE VECTORES DE INTERRUPCION
		MOV ES, CX
		; GUARDAMOS EL SEGMENTO ASIGNADO A 60h EN CX
		MOV CX, ES:[60h*4+2]
		; COMPROBAMOS SI EL SEGMENTO QUE GUARDAMOS ES IGUAL A 0
		CMP CX, 0
		; SI EL  SEGMENTO ES 0 SABEMOS QUE NUESTRO DRIVER NO ESTA INSTALADO ASI QUE SALTAMOS A LA RUTINA NO_INSTALADO
		JE no_instalado_rut
		; SI EL SEGMENTO ES DISTINTO DE 0 PASAMOS A COMPROBAR SI ES EL SEGMENTO DE NUESTRO DRIVER
		CALL comprobacion_driver
		; COMPROBAMOS EL VALOR DE AX PARA SABER SI NUESTRO DRIVER ESTA INSTALADO
		CMP AX, 1
		; SI AX ES 1 NUESTRO DRIVER ESTA INSTALADO Y SALTAMOS A LA RUTINA INSTALADO
		JE instalado_rut
		; SI AX NO ES 1 NUESTRO DRIVER NO ESTA INSTALADO
		JMP no_instalado_rut
		no_instalado_rut:
			; IMPRIMIMOS EL SALTO DE LINEA
			CALL imprimir_intro
			; IMPRIMIMOS QUE NO ESTA INSTALADO
			CALL no_instalado
			; VOLVEMOS DONDE SE HA LLAMADO LA RUTINA
			RET
		instalado_rut:
			; IMPRIMIMOS EL SALTO DE LINEA
			CALL imprimir_intro
			; IMPRIMIMOS QUE ESTA INSTALADO
			CALL instalado
			; VOLVEMOS DONDE SE HA LLAMADO LA RUTINA
			RET
	no_argumentos_proc ENDP
	
	argumentos_proc PROC
		; COMPROBAMOS QUE HAY 3 ARGUMENTOS GUARDADOS
		CMP AL, 3
		; SI NO ES IGUAL SALTAMOS A FIN
		JNE fin3
		; MOVEMOS A AX EL PRIMER ARGUMENTO
		MOV AL, CS:[81h]
		; COMPROBAMOS QUE EL PRIMER ARGUMENTO ES UN ESPACIO
		CMP AL, 32 
		; SI NO ES IGUAL SALTAMOS A FIN
		JNE fin3
		; SI ES IGUAL SEGUMOS COMPROBANDO ARGUMENTOS, MOVEMOS A AX EL SEGUNDO ARGUMENTO
		MOV AL, CS:[82h]
		;COMPROBAMOS QUE EL SEGUNDO ARGUMENTO ES UNA "/"
		CMP AL, 47
		; SI NO ES IGUAL SALTAMOS A FIN
		JNE fin3
		; SI LO ES COMPROBAMOS EL TERCER ARGUMENTO, MOVEMOS A AX EL TERCER ARGUMENTO
		MOV AL, CS:[83h]
		; COMPROBAMOS QUE SEA IGUAL A "I"
		CMP AL, 73
		; SI ES IGUAL SALTAMOS A LA RUTINA INSTALAR
		JE instalador_rut
		; SI NO, COMPROBAMOS QUE SEA IGUAL A "D"
		CMP AL, 68
		; SI ES IGUAL SALTAMOS A LA RUTINA DESINTALAR
		JE desinstalar_rut
		; SI NO ES IGUAL A NINGUNA SALTAMOS FIN
		JMP fin3
		instalador_rut:
			; LLAMAMOS A LA RUTINA QUE INSTALA
			CALL instalador
			; VOLVEMOS DONDE SE HA LLAMADO A LA RUTINA
			RET
		desinstalar_rut:
			; LLAMAMOS A LA RUTINA QUE DESINSTALA
			CALL desinstalar_60h
			; VOLVEMOS DONDE SE HA LLAMADO A LA RUTINA
			RET
		fin3:
			; LLAMAMOS A LA RUTINA PARA IMPRIMIR QUE LOS ARGUMENTOS NO SON VALIDOS
			CALL argumentos_no_validos
			; VOLVEMOS DONDE SE HA LLAMADO LA RUTINA
			RET
	argumentos_proc ENDP
		
	comprobacion_driver PROC
		; PONEMOS AX A 0
		XOR AX, AX
		; COLOCAMOS ES EN EL SEGMENTO 0
		MOV ES, AX
		; GUARDAMOS EL SEGMENTO ASIGNADO A 60h EN CX
		MOV CX, ES:[60h*4+2]
		; COMPROBAMOS SI EL SEGMENTO ES 0
		CMP CX, 0
		; SI ES 0 SALTAMOS A LA RUTINA DRIVER_NOT
		JE driver_not
		; GUARDAMOS EL  SEGMENTO ASIGNADO A LA INTERRUPCION 60h EN DS
		MOV DS, CX
		; GUARDAMOS EL OFFSET ASIGNADO A LA INTERRUPCION 60h EN BX
		MOV BX, ES:[60h*4]
		; NOS MOVEMOS  2 BYTES ANTES DEL CODIGO QUE EJECUTA LA INTERRUPCION(ZONA EN LA QUE SE ENCUENTRA NUESTRA FLAG DE COMPROBACION)
		MOV DX, DS:[BX-2]
		; COMPROBAMOS SI ESTA VARIABLE TIENE EL VALOR QUE LE HEMOS ASIGNADO A NUESTRO DRIVER
		CMP DX, 0CAFEh
		; SI COINCIDE CON NUESTRA VARIABLE FLAG SALTAMOS A LA RUTINA DRIVER_AX
		JE driver_ax
		; SI NO GUARDAMOS 0 EN AX
		MOV AX, 0
		; VOLVEMOS DONDE SE HA LLAMADO EL PROCEDIMIENTO
		RET
		driver_ax:
			MOV AX, 1
			RET
		driver_not:
			MOV AX, 0
			RET
	comprobacion_driver ENDP

	no_instalado PROC
		; GUARDAMOS EL CS EN BX PARA PODER ASIGNARLO A CONTINUACION A DS
		MOV BX, CS
		; COLOCAMOS DS EN CS PARA IMPRIMIR CORRECTAMENTE
		MOV DS, BX
		; GUARDAMOS EN DX EL OFFSET DEL STRING QUE VAMOS A IMPRIMIR
		MOV DX, OFFSET string_no_instalado
		; GUARDAMOS EN AH 9 PARA IMPRIMIR CON LA INTERRUPCION 21h
		MOV AH, 9
		; IMPRIMIMOS LLAMANDO A LA INTERRUPCION 21h
		INT 21h
		; VOLVEMOS DONDE SE HA LLAMADO LA RUTINA
		RET
	no_instalado ENDP
	
	instalado PROC
		; GUARDAMOS EL CS EN BX PARA PODER ASIGNARLO A CONTINUACION A DS
		MOV BX, CS
		; COLOCAMOS DS EN CS PARA IMPRIMIR CORRECTAMENTE
		MOV DS, BX
		; GUARDAMOS EN DX EL OFFSET DEL STRING QUE VAMOS A IMPRIMIR
		MOV DX, OFFSET string_instalado
		; GUARDAMOS EN AH 9 PARA IMPRIMIR CON LA INTERRUPCION 21h
		MOV AH, 9
		; IMPRIMIMOS LLAMANDO A LA INTERRUPCION 21h
		INT 21h
		; VOLVEMOS DONDE SE HA LLAMADO LA RUTINA
		RET
	instalado ENDP
	
	info PROC 
		; GUARDAMOS EL CS EN BX PARA PODER ASIGNARLO A CONTINUACION A DS
		MOV BX, CS
		; COLOCAMOS DS EN CS PARA IMPRIMIR CORRECTAMENTE
		MOV DS, BX
		; GUARDAMOS EN DX EL OFFSET DEL STRING QUE VAMOS A IMPRIMIR
		MOV DX, OFFSET string_info
		; GUARDAMOS EN AH 9 PARA IMPRIMIR CON LA INTERRUPCION 21h
		MOV AH, 9
		; IMPRIMIMOS LLAMANDO A LA INTERRUPCION 21h
		INT 21h
		; VOLVEMOS DONDE SE HA LLAMADO LA RUTINA
		RET
	info ENDP
	
	argumentos_no_validos PROC
		; GUARDAMOS EL CS EN BX PARA PODER ASIGNARLO A CONTINUACION A DS
		MOV BX, CS
		; COLOCAMOS DS EN CS PARA IMPRIMIR CORRECTAMENTE
		MOV DS, BX
		; GUARDAMOS EN DX EL OFFSET DEL STRING QUE VAMOS A IMPRIMIR
		MOV DX, OFFSET no_validos
		; GUARDAMOS EN AH 9 PARA IMPRIMIR CON LA INTERRUPCION 21h
		MOV AH, 9
		; IMPRIMIMOS LLAMANDO A LA INTERRUPCION 21h
		INT 21h
		; VOLVEMOS DONDE SE HA LLAMADO LA RUTINA
		RET
	argumentos_no_validos ENDP
	
	imprimir_intro PROC
		; GUARDAMOS EL CS EN BX PARA PODER ASIGNARLO A CONTINUACION A DS
		MOV BX, CS
		; COLOCAMOS DS EN CS PARA IMPRIMIR CORRECTAMENTE
		MOV DS, BX
		; GUARDAMOS EN DX EL OFFSET DEL STRING QUE VAMOS A IMPRIMIR
		MOV DX, OFFSET intro
		; GUARDAMOS EN AH 9 PARA IMPRIMIR CON LA INTERRUPCION 21h
		MOV AH, 9
		; IMPRIMIMOS LLAMANDO A LA INTERRUPCION 21h
		INT 21h
		; VOLVEMOS DONDE SE HA LLAMADO LA RUTINA
		RET
	imprimir_intro ENDP
	
	imprimir_instalado_previo PROC
		; GUARDAMOS EL CS EN BX PARA PODER ASIGNARLO A CONTINUACION A DS
		MOV BX, CS
		; COLOCAMOS DS EN CS PARA IMPRIMIR CORRECTAMENTE
		MOV DS, BX
		; GUARDAMOS EN DX EL OFFSET DEL STRING QUE VAMOS A IMPRIMIR
		MOV DX, OFFSET instalado_previamente
		; GUARDAMOS EN AH 9 PARA IMPRIMIR CON LA INTERRUPCION 21h
		MOV AH, 9
		; IMPRIMIMOS LLAMANDO A LA INTERRUPCION 21h
		INT 21h
		; VOLVEMOS DONDE SE HA LLAMADO LA RUTINA
		RET
	imprimir_instalado_previo ENDP
	
	imprimir_no_instalado_previo PROC
		; GUARDAMOS EL CS EN BX PARA PODER ASIGNARLO A CONTINUACION A DS
		MOV BX, CS
		; COLOCAMOS DS EN CS PARA IMPRIMIR CORRECTAMENTE
		MOV DS, BX
		; GUARDAMOS EN DX EL OFFSET DEL STRING QUE VAMOS A IMPRIMIR
		MOV DX, OFFSET no_instalado_previamente
		; GUARDAMOS EN AH 9 PARA IMPRIMIR CON LA INTERRUPCION 21h
		MOV AH, 9
		; IMPRIMIMOS LLAMANDO A LA INTERRUPCION 21h
		INT 21h
		; VOLVEMOS DONDE SE HA LLAMADO LA RUTINA
		RET
	imprimir_no_instalado_previo ENDP
	
	imprimir_instalado_correcto PROC
		; GUARDAMOS EL CS EN BX PARA PODER ASIGNARLO A CONTINUACION A DS
		MOV BX, CS
		; COLOCAMOS DS EN CS PARA IMPRIMIR CORRECTAMENTE
		MOV DS, BX
		; GUARDAMOS EN DX EL OFFSET DEL STRING QUE VAMOS A IMPRIMIR
		MOV DX, OFFSET instalado_correcto
		; GUARDAMOS EN AH 9 PARA IMPRIMIR CON LA INTERRUPCION 21h
		MOV AH, 9
		; IMPRIMIMOS LLAMANDO A LA INTERRUPCION 21h
		INT 21h
		; VOLVEMOS DONDE SE HA LLAMADO LA RUTINA
		RET
	imprimir_instalado_correcto ENDP
	
	imprimir_desinstalado_correcto PROC
		; GUARDAMOS EL CS EN BX PARA PODER ASIGNARLO A CONTINUACION A DS
		MOV BX, CS
		; COLOCAMOS DS EN CS PARA IMPRIMIR CORRECTAMENTE
		MOV DS, BX
		; GUARDAMOS EN DX EL OFFSET DEL STRING QUE VAMOS A IMPRIMIR
		MOV DX, OFFSET desintalado_correcto
		; GUARDAMOS EN AH 9 PARA IMPRIMIR CON LA INTERRUPCION 21h
		MOV AH, 9
		; IMPRIMIMOS LLAMANDO A LA INTERRUPCION 21h
		INT 21h
		; VOLVEMOS DONDE SE HA LLAMADO LA RUTINA
		RET
	imprimir_desinstalado_correcto ENDP
	
codigo ENDS
END inicio

