
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

    ; nie znaleziono odpowiedniego operatora->popros o wprowadzenie ponownie
    JMP ZNAK_DZIALANIA

WYNIK
    LXI H,SYM_NOWALINIA
    RST 3

    LXI H,WYN_DZIALANIA
    RST 3

    ; skok pod warunkiem C=1
    CC WYNIK_Przen

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
    RET

; neguje liczbe znajdujaca sie w rejestrach DE
NEGACJA
    MOV A,B
    ; negacja bitow akumulatora
    CMA
    MOV B,A

    MOV A,C
    CMA
    MOV C,A
    
    RET

; Dodaje DE do BC i zapisuje wynik w BC(kolejnosc starszy bajt-mlodszy bajt)
DODAWANIE
    CALL WCZYTAJ_LICZBE
    ; pierwsze dodawanie mozna wykonac bez przeniesienia
    MOV A,C
    ADD E
    MOV C,A

    ; drugie juz trzeba, gdyz moglo na 8-osmym bicie nastapic przeniesienie
    MOV A,B
    ADC D
    MOV B,A
    JMP Wynik
    
; wyswietla jedynke na znak, ze nastapilo przeniesienie
WYNIK_Przen
    MVI A,'1'
    RST 1
    RET


; "assety"
SYM_NOWALINIA    DB 10,13,'@'
WPR_OPERAND 	 DB 'Wprowadz operand',10,13,'@' 
WPR_DZIALANIE 	 DB 'Wprowadz znak dzialania(+ - !)',10,13,'@' 
WPR_OPERAND2 	 DB 'Wprowadz operand 2',10,13,'@' 
ZLE_DZIALANIE	 DB 'Wprowadzono zly znak. @' 
ZLE_DZIALANIE2 	 DB 'Wprowadz znak dzialania ponownie',10,13,'@'
WYN_DZIALANIA 	 DB 'Wynik: @'