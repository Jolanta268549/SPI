;8.01.2024 SPI
;NIE WYSY£AMY NIC TYLKO ODBIERAMY

;
; 80124.asm
;
; Created: 08.01.2024 14:19:03
; Author : Student
;


; Replace with your application code
//start:
//inc r16
// rjmp start



;.include "m8535def.inc"

;LDI R16, low(RAMEND)
;OUT SPL, R16
;LDI R16, high(RAMEND)
;OUT SPH, R16

;konfiguracja wyprowadzeñ
LDI R16, 0b10110000
OUT DDRB,R16 ;konfiguracja wyprowadzeñ MASTERa (SCK MOSI,MISO,SS)
SBI PORTB,4 ;zapewnienie '1' na nó¿ce SS MASTERa
SBI DDRB, 0 ;do sterowania nó¿k¹ SS SLAVEa
SBI PORTB,0 ;stan bezczynoœci SPI
LDI R19, 0b11111111
OUT DDRC, R19

;konfiguracja rejestru sterujacego
LDI R16,0b01010000
OUT SPCR,R16 ;praca w trybie MASTER, transmisja od MSB


;start transmisji
;LDI R17,$0C ;bajt nr 1 (od MASTER do SLAVE)
;LDI R18,$01 ;bajt nr 2 (od MASTER do SLAVE)
LDI R19,0 ;R19 do odebrania bajtu nr 3 (od SLAVE)
LDI R20,0 ;R20 do odebrania bajtu nr 4 (od SLAVE)



nic:
RCALL wyslij

OUT PORTC, R19
//PETLA
delay0:
ldi R21, 250
dec R21
OUT PORTC, R20
;PETLA
delay1:
ldi R22, 250
dec R22

RJMP nic

wyslij:
CBI PORTB,0 ;nó¿ka S5 SLAVEa na '0' - start sesji

;OUT SPDR,R17 ;bajt nr 1 (wysy³anie) - automatyczny start transmisji
;RCALL czekaj ;...a¿ wyœle ca³y bajt z SPDR

;OUT SPDR,R18 ;bajt nr 2 (wysy³anie)
;RCALL czekaj

OUT SPDR,R19 ;odbiór bajtu nr 3: wysy³amy cokolwiek
RCALL czekaj
IN R19,SPDR ;...a SLAVE "odpowiada" bajtem nr 3 (kopiujemy go z SPDR)

OUT SPDR,R20 ;odbiór bajtu nr 4: SLAVE nie mo¿e nadawaæ samodzielnie
RCALL czekaj
IN R20,SPDR ;...wysy³a dane wtedy i tylko wtedy, gdy nadaje MASTER
;(full duplex)
SBI PORTB,0 ;nó¿ka SS SLAVEa na '1' - konec sesji
RET



czekaj:
SBIS SPSR,SPIF ;testowanie flagi SPIF
RJMP czekaj
RET