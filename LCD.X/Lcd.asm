
    ; PIC16F877A Configuration Bit Settings

    ; ASM source line config statements

    #include "p16f877a.inc"

    ; CONFIG
    ; __config 0xFFBA
     __CONFIG _FOSC_HS & _WDTE_OFF & _PWRTE_OFF & _BOREN_OFF & _LVP_ON & _CPD_OFF & _WRT_OFF & _CP_OFF

    #define BANCO0   bcf STATUS, RP0
    #define BANCO1   bsf STATUS, RP0

     CBLOCK 20h
     contador
     contador2
     endc

 org 0
    BANCO1

    movlw 0
    movwf TRISD         ; Porta D � saida

    movlw b'11101100'   ; PSPMODE=0 para porta D ser I/O
    movwf TRISE         ; Bits 0 e 1 da porta E sao saidas

    movlw b'00001110'   ; Pinos configurados como digitais
    movwf ADCON1
    
    movlw b'00000111'   ; Timer 0 com clock interno e prescaler 256
    movwf OPTION_REG
    
    BANCO0

    movlw b'00110001'   ; Timer 1 com clock interno e prescaler 8
    movwf T1CON

    call  inicia_lcd

    movlw 'A'
    call  escreve_dado_lcd

    call espera_1s_timer1

    movlw 'B'
    call  escreve_dado_lcd

    call espera_1s_timer1

    movlw 'C'
    call  escreve_dado_lcd

    goto  $              ; Trava programa

espera_1s_timer1
    movlw 2                
    movwf contador
    movlw 0Bh               ; Valor para 62500 contagens (500ms)
    movwf TMR1L             ; 65536 - 62500 = 3036 => 0BDCh      
    movlw 0DCh
    movwf TMR1H
aguarda_estouro_timer1
    btfss PIR1, TMR1IF    ; Espera timer1 estourar
    goto  aguarda_estouro_timer1
    movlw 0Bh               ; Reprograma para 62500 contagens (500ms)
    movwf TMR1L             ; 65536 - 62500 = 3036 => 0BDCh      
    movlw 0DCh
    movwf TMR1H
    bcf   PIR1, TMR1IF      ; Limpa flag de estouro
    decfsz contador         ; Aguarda 2 ocorrencias ( 2x500ms= 1s)
    goto  aguarda_estouro_timer1
    return

espera_1s
    movlw 20                
    movwf contador
    movlw 60                ; Valor para 196 contagens (50ms)
    movwf TMR0              ; 256 - 196 = 60      
aguarda_estouro
    btfss INTCON, TMR0IF    ; Espera timer0 estourar
    goto  aguarda_estouro
    movlw 60                ; Reprograma para 196 contagens (50ms)
    movwf TMR0              ; 256 - 196 = 60
    bcf   INTCON, TMR0IF    ; Limpa flag de estouro
    decfsz contador         ; Aguarda 20 ocorrencias ( 20x50ms= 1s)
    goto  aguarda_estouro
    return

inicia_lcd
    movlw 38h
    call  escreve_comando_lcd
    movlw 38h
    call  escreve_comando_lcd
    movlw 38h
    call  escreve_comando_lcd
    movlw 0Ch
    call  escreve_comando_lcd
    movlw 06h
    call  escreve_comando_lcd
    movlw 01h
    call  escreve_comando_lcd
    call  atraso_limpa_lcd
    return

escreve_comando_lcd
    bcf   PORTE, RE0    ; Define comando no LCD (RS=0)
    movwf PORTD
    bsf   PORTE, RE1     ; Ativa ENABLE do LCD
    bcf   PORTE, RE1     ; Desativa ENABLE do LCD
    call  atraso_lcd
    return

escreve_dado_lcd
    bsf   PORTE, RE0    ; Define dado no LCD (RS=1)
    movwf PORTD
    bsf   PORTE, RE1     ; Ativa ENABLE do LCD
    bcf   PORTE, RE1     ; Desativa ENABLE do LCD
    call  atraso_lcd
    return

atraso_lcd                 ; Atraso de 40us para LCD
    movlw 26               ; 8 clocks
    movwf contador         ; 4 clocks
ret_atraso_lcd
    decfsz contador        ; 8 clocks
    goto ret_atraso_lcd    ; 4 clocks
    return

atraso_limpa_lcd
    movlw 40
    movwf contador2
ret_atraso_limpa_lcd
    call atraso_lcd
    decfsz contador2
    goto ret_atraso_limpa_lcd
    return

 end
