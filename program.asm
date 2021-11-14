
	ORG 800H  

    ; Wyswietlenie menu
	LXI H,WPR_OPERAND  
	RST 3
    RST 5

    LXI H,SYM_NOWALINIA
    RST 3

    ; przekopiowanie wartosci do rejestrow pomocniczych
    MOV B,D
    MOV C,E     

; petla wykonujaca sie dopoki nie znaleziono odpowiedniego znaku
ZNAK_DZIALANIA
    LXI H,WPR_DZIALANIE
    RST 3
    RST 2

    LXI H,SYM_NOWALINIA
    RST 3

    ; wyszukiwanie wprowadzonego operatora

    CPI '!'
    CZ NEGACJA
    JZ WYNIK
    
    CPI '+'
    JZ DODAWANIE

    CPI '-'
    JZ ODEJMOWANIE
    ; nie znaleziono odpowiedniego operatora->popros o wprowadzenie ponownie
    JMP ZNAK_DZIALANIA

WYNIK
    LXI H,WYN_DZIALANIA
    RST 3

    ; w wyniku dzialania metody cos zostalo zapisane w akumulatorze
    RST 1

    MOV A,B
    RST 4

    MOV A,C
    RST 4
	HLT  

; wczytuje liczbe i zapisuje w rejestrach DE
WCZYTAJ_LICZBE
    LXI H,WPR_OPERAND2
    RST 3
    RST 5

    LXI H,SYM_NOWALINIA
    RST 3
    RET

; neguje liczbe znajdujaca sie w rejestrach BC
NEGACJA
    MOV A,B
    ; negacja bitow akumulatora
    CMA
    MOV B,A

    MOV A,C
    CMA
    MOV C,A
    
    MVI A,0
    RET

; Dodaje DE do BC i zapisuje wynik w BC(kolejnosc starszy bajt-mlodszy bajt)
; zapisuje pod koniec w A '1', jesli bylo przeniesienie na najstarszym bicie 
DODAWANIE
    CALL WCZYTAJ_LICZBE
    XCHG
    DAD B
    XCHG

    MOV B,D
    MOV C,E

    MVI A,0
    CC POKAZ_1

    JMP Wynik

POKAZ_1
    MVI A,'1'
    RET
  
; odejmuje liczby bez znaku w ZM
; ZM gdy odejmuje sie, to sie sprawdza moduly liczb( w tym przypadku cala liczbe)
; jesli pierwszy jest mniejszy, to nalezy go zamienic z drugim i ustawic bit znaku na 1
; potem wykonujemy "zwyczajne" odejmowanie liczb binarnych
; Wynik znajduje sie w parze BC oraz zapisuje w akumulatorze -, jesli nastapila pozyczka na ostatnim bicie
ODEJMOWANIE
    CALL WCZYTAJ_LICZBE
    
    ; porownanie pierwsza z druga
    MOV A,B
    CMP D
    MVI H,0
    JZ TE_SAME
    ; odejmij, gdy sa pierwsza > druga
    JNC ZW_ODEJMOWANIE

; pierwsza jest mniejsza od drugiej
ZAMIANA
    PUSH B
    MOV B,D
    MOV C,E
    POP D

    ; jezeli byla zamiana wyswietl -
    MVI H,'-'
    CMC

    JMP ZW_ODEJMOWANIE
    
; te same starsze 8-bit
TE_SAME
    MOV A,C
    CMP E
    JM ZAMIANA

ZW_ODEJMOWANIE
    MOV A,C
    SUB E
    MOV C,A

    MOV A,B
    SBB D
    MOV B,A

    MOV A,H
    JMP Wynik

; "assety"
SYM_NOWALINIA    DB 10,13,'@'
WPR_OPERAND 	 DB 'Wprowadz operand',10,13,'@' 
WPR_DZIALANIE 	 DB 'Wprowadz znak dzialania(+ - !)',10,13,'@' 
WPR_OPERAND2 	 DB 'Wprowadz operand 2',10,13,'@' 
ZLE_DZIALANIE	 DB 'Wprowadzono zly znak. @' 
ZLE_DZIALANIE2 	 DB 'Wprowadz znak dzialania ponownie',10,13,'@'
WYN_DZIALANIA 	 DB 'Wynik: @'